import { execFileSync } from "node:child_process";
import {
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { chromium } from "@playwright/test";
import { createServer } from "vite";

const semverPattern = /^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/;
const version = process.argv[2];
if (!version || !semverPattern.test(version)) {
  console.error("usage: yarn verify:published <exact-version>");
  process.exit(2);
}

const moonMod = readFileSync("moon.mod", "utf8");
const domFfiVersions = [
  ...moonMod.matchAll(/^\s*"tiye\/dom-ffi@([^"]+)",?$/gm),
].map((match) => match[1]);
if (domFfiVersions.length !== 1 || !semverPattern.test(domFfiVersions[0])) {
  throw new Error(
    `expected one exact tiye/dom-ffi dependency in moon.mod, found ${JSON.stringify(domFfiVersions)}`,
  );
}
const domFfiVersion = domFfiVersions[0];

const directory = mkdtempSync(join(tmpdir(), "react-mbt-published-"));
const results = [];

function run(command, args, options = {}) {
  const startedAt = Date.now();
  try {
    const output = execFileSync(command, args, {
      cwd: directory,
      encoding: "utf8",
      env: { ...process.env, ...options.env },
      stdio: ["ignore", "pipe", "pipe"],
    });
    results.push({
      command: [command, ...args].join(" "),
      durationMs: Date.now() - startedAt,
      status: "passed",
    });
    if (output.trim()) console.log(output.trim());
    return output;
  } catch (error) {
    if (error.stdout) process.stdout.write(error.stdout);
    if (error.stderr) process.stderr.write(error.stderr);
    throw error;
  }
}

async function verifyBrowserRuntime() {
  const startedAt = Date.now();
  const diagnostics = [];
  let server;
  let browser;
  try {
    server = await createServer({
      root: directory,
      logLevel: "silent",
      server: { host: "127.0.0.1", port: 0 },
    });
    await server.listen();
    const url = server.resolvedUrls?.local[0];
    if (!url) throw new Error("Vite did not report a downstream fixture URL");

    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();
    page.on("console", (message) => {
      if (["warning", "error"].includes(message.type())) {
        diagnostics.push(`${message.type()}: ${message.text()}`);
      }
    });
    page.on("pageerror", (error) => diagnostics.push(`pageerror: ${error.message}`));

    await page.goto(url);
    const rendered = page.locator("#published-render-ok");
    await rendered.waitFor();
    const renderText = await rendered.textContent();
    if (renderText !== "Published render") {
      throw new Error(`unexpected client render text: ${renderText}`);
    }

    const hydrationReused = await page.evaluate(
      () =>
        globalThis.__publishedHydrationNode ===
        document.querySelector("#published-hydration-button"),
    );
    if (!hydrationReused) {
      throw new Error("hydrate_root replaced the server DOM node");
    }

    const hydrationButton = page.locator("#published-hydration-button");
    await hydrationButton.click();
    await page.waitForFunction(
      () =>
        document.querySelector("#published-hydration-button")?.textContent ===
        "Published clicks: 1",
    );
    if (diagnostics.length > 0) {
      throw new Error(
        `unexpected downstream browser diagnostics: ${JSON.stringify(diagnostics)}`,
      );
    }

    results.push({
      command: "downstream Chromium render and hydration runtime",
      durationMs: Date.now() - startedAt,
      status: "passed",
    });
    return {
      browserRuntimeScenarios: 3,
      renderNodes: 1,
      hydrationNodesReused: 1,
      postHydrationUpdates: 1,
      browserDiagnostics: diagnostics.length,
    };
  } finally {
    if (browser) await browser.close();
    if (server) await server.close();
  }
}

try {
  writeFileSync(
    join(directory, "moon.mod"),
    `name = "release-check/react-downstream"\n\nversion = "0.0.0"\n\nimport {\n  "tiye/react@${version}",\n  "tiye/dom-ffi@${domFfiVersion}",\n}\n\npreferred_target = "js"\n`,
  );
  writeFileSync(
    join(directory, "moon.pkg"),
    'import {\n  "tiye/react" @react,\n}\n',
  );
  writeFileSync(
    join(directory, "smoke.mbt"),
    "pub fn release_smoke() -> @react.VirtualNode {\n  @react.table([])\n}\n",
  );

  mkdirSync(join(directory, "server"));
  writeFileSync(
    join(directory, "server", "moon.pkg"),
    'import {\n  "tiye/react" @react,\n}\n\npkgtype(kind: "executable")\n',
  );
  writeFileSync(
    join(directory, "server", "main.mbt"),
    `fn main {
  let html = @react.render_to_string(
    @react.div([@react.Text("Published SSR")]),
  )
  if html != "<div>Published SSR</div>" {
    abort("unexpected published-package SSR output: \\{html}")
  }
  println("Published package SSR runtime passed: 1/1")
}
`,
  );

  mkdirSync(join(directory, "browser"));
  writeFileSync(
    join(directory, "browser", "moon.pkg"),
    'import {\n  "tiye/react" @react,\n  "tiye/dom-ffi" @dom,\n}\n\nsupported_targets = "+js"\n\npkgtype(kind: "executable")\n',
  );
  writeFileSync(
    join(directory, "browser", "main.mbt"),
    `priv struct PublishedHydrationProps {}

fn comp_published_hydration(
  _props : PublishedHydrationProps,
) -> @react.VirtualNode {
  let (clicks, set_clicks) = @react.use_state_with_updater(0)
  @react.button(
    id="published-hydration-button",
    on_click=fn(_) {
      set_clicks(@react.Update(fn(current) { current + 1 }))
    },
    [@react.Text("Published clicks: \\{clicks}")],
  )
}

fn main {
  let document = @dom.window().document()
  match document.get_element_by_id("published-render-root") {
    Some(root) =>
      @react.render(
        @react.div(id="published-render-ok", [@react.Text("Published render")]),
        root,
      )
    None => abort("missing published-render-root")
  }
  match document.get_element_by_id("published-hydration-root") {
    Some(root) =>
      @react.hydrate_root(
        @react.component(
          comp_published_hydration,
          PublishedHydrationProps::{  },
          [],
        ),
        root,
      )
    None => abort("missing published-hydration-root")
  }
}
`,
  );
  writeFileSync(
    join(directory, "index.html"),
    `<!doctype html>
<html>
  <body>
    <div id="published-render-root"></div>
    <div id="published-hydration-root"><button id="published-hydration-button">Published clicks: 0</button></div>
    <script type="module">
      import * as React from "react";
      import * as ReactDOMClient from "react-dom/client";
      globalThis.React = React;
      globalThis.ReactDOMClient = ReactDOMClient;
      globalThis.__publishedHydrationNode = document.querySelector("#published-hydration-button");
      await import("/_build/js/debug/build/browser/browser.js");
    </script>
  </body>
</html>
`,
  );
  symlinkSync(
    resolve("node_modules"),
    join(directory, "node_modules"),
    process.platform === "win32" ? "junction" : "dir",
  );

  run("moon", ["update"]);
  const tree = run("moon", ["tree"]);
  if (!tree.includes(`tiye/react@${version}`)) {
    throw new Error(`resolved dependency tree does not contain tiye/react@${version}`);
  }
  if (!tree.includes(`tiye/dom-ffi@${domFfiVersion}`)) {
    throw new Error(
      `resolved dependency tree does not contain tiye/dom-ffi@${domFfiVersion}`,
    );
  }
  run("moon", ["check", "--target", "js"]);
  run("moon", ["build", "--target", "js"]);
  run("moon", ["run", "server", "--target", "js"], {
    env: {
      NODE_OPTIONS: `--import=${resolve("scripts/register-react-server.mjs")}`,
    },
  });
  const browserEvidence = await verifyBrowserRuntime();

  console.log(
    JSON.stringify(
      {
        module: "tiye/react",
        exactVersion: version,
        exactDomFfiVersion: domFfiVersion,
        downstreamCommandsPassed: results.length,
        generatedSmokeNodes: ["table", "div", "button"],
        serverRuntimeScenarios: 1,
        ...browserEvidence,
        results,
      },
      null,
      2,
    ),
  );
} finally {
  rmSync(directory, { recursive: true, force: true });
}
