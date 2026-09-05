import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { chromium, expect } from "@playwright/test";
import { preview } from "vite";
import { hasResolvedPackageVersion } from "./release-verification.mjs";

// Only these flat filenames can be materialized from the documentation.
const expectedFiles = [
  "moon.mod", "moon.pkg", "package.json", "index.html", "main.mjs", "main.mbt",
];
const readme = readFileSync(new URL("../README.md", import.meta.url), "utf8");
const matches = [...readme.matchAll(
  /<!-- quick-start:file ([^\n]+) -->\r?\n```[^\n]*\r?\n([\s\S]*?)\r?\n```/g,
)];
assert.deepEqual(matches.map((match) => match[1]).sort(), [...expectedFiles].sort());

const directory = mkdtempSync(join(tmpdir(), "react-mbt-quick-start-"));
let server;
let browser;
const commands = [];
function run(command, args) {
  console.log(`Quick Start: ${command} ${args.join(" ")}`);
  const output = execFileSync(command, args, {
    cwd: directory,
    encoding: "utf8",
    timeout: 180_000,
    stdio: ["ignore", "pipe", "pipe"],
  });
  commands.push([command, ...args].join(" "));
  return output;
}

try {
  for (const [, name, source] of matches) {
    writeFileSync(join(directory, name), `${source}\n`);
  }
  run("moon", ["update"]);
  const tree = run("moon", ["tree"]);
  const declaredDependencies = [...readFileSync(join(directory, "moon.mod"), "utf8")
    .matchAll(/"(tiye\/(?:react|dom-ffi))@([^"\n]+)"/g)];
  assert.equal(declaredDependencies.length, 2);
  for (const [, name, version] of declaredDependencies) {
    assert.ok(hasResolvedPackageVersion(tree, name, version), `${name}@${version}`);
  }
  run("npm", ["install", "--no-audit", "--no-fund"]);
  run("moon", ["check", "--target", "js"]);
  run("npm", ["run", "build"]);

  server = await preview({
    root: directory,
    configFile: false,
    preview: { host: "127.0.0.1", port: 0 },
  });
  const url = server.resolvedUrls?.local[0];
  assert.ok(url, "Vite preview must expose the production build");
  browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const diagnostics = [];
  page.on("pageerror", (error) => diagnostics.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      diagnostics.push(`${message.type()}: ${message.text()}`);
    }
  });
  await page.addInitScript(() => {
    globalThis.__quickStartRejections = [];
    addEventListener("unhandledrejection", (event) => {
      globalThis.__quickStartRejections.push(String(event.reason));
    });
  });
  await page.goto(url);
  const counter = page.getByRole("button");
  await expect(counter).toHaveCount(1);
  await expect(counter).toHaveText("Count: 0");
  for (let count = 1; count <= 3; count++) {
    await counter.click();
    await expect(counter).toHaveText(`Count: ${count}`);
  }
  assert.deepEqual(await page.evaluate(() => globalThis.__quickStartRejections), []);
  assert.deepEqual(diagnostics, []);

  const missingRootPage = await browser.newPage();
  const missingRootErrors = [];
  const missingRootDiagnostics = [];
  missingRootPage.on("pageerror", (error) => missingRootDiagnostics.push(error.message));
  missingRootPage.on("console", (message) => {
    if (message.type() === "error") missingRootErrors.push(message.text());
    if (message.type() === "warning") missingRootDiagnostics.push(message.text());
  });
  await missingRootPage.addInitScript(() => {
    globalThis.__quickStartRejections = [];
    addEventListener("unhandledrejection", (event) => {
      globalThis.__quickStartRejections.push(String(event.reason));
    });
  });
  await missingRootPage.route(url, async (route) => {
    const response = await route.fetch();
    const html = await response.text();
    assert.ok(html.includes('id="app"'));
    await route.fulfill({ response, body: html.replace('id="app"', 'id="missing"') });
  });
  await missingRootPage.goto(url);
  await expect.poll(() => missingRootErrors.length).toBe(1);
  assert.deepEqual(missingRootErrors, ["Missing #app mount element; rendering skipped"]);
  await expect(missingRootPage.getByRole("button")).toHaveCount(0);
  assert.deepEqual(missingRootDiagnostics, []);
  assert.deepEqual(await missingRootPage.evaluate(() => globalThis.__quickStartRejections), []);

  console.log(JSON.stringify({
    extractedFiles: matches.length,
    dependencies: declaredDependencies.map(([, name, version]) => `${name}@${version}`),
    commandsPassed: commands,
    productionBrowserScenarios: 2,
    initialButtons: 1,
    clickUpdates: 3,
    diagnostics: diagnostics.length,
    expectedMissingRootErrors: missingRootErrors.length,
  }, null, 2));
} catch (error) {
  if (error.stdout) process.stdout.write(error.stdout);
  if (error.stderr) process.stderr.write(error.stderr);
  throw error;
} finally {
  try {
    if (browser) await browser.close();
  } finally {
    if (server) await new Promise((resolve, reject) => {
      server.httpServer.close((error) => error ? reject(error) : resolve());
    });
    rmSync(directory, { recursive: true, force: true });
  }
}
