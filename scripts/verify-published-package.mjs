import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const version = process.argv[2];
if (!version || !/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/.test(version)) {
  console.error("usage: yarn verify:published <exact-version>");
  process.exit(2);
}

const directory = mkdtempSync(join(tmpdir(), "react-mbt-published-"));
const results = [];

function run(command, args) {
  const startedAt = Date.now();
  try {
    const output = execFileSync(command, args, {
      cwd: directory,
      encoding: "utf8",
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

try {
  writeFileSync(
    join(directory, "moon.mod"),
    `name = "release-check/react-downstream"\n\nversion = "0.0.0"\n\nimport {\n  "tiye/react@${version}",\n}\n\npreferred_target = "js"\n`,
  );
  writeFileSync(
    join(directory, "moon.pkg"),
    'import {\n  "tiye/react" @react,\n}\n',
  );
  writeFileSync(
    join(directory, "smoke.mbt"),
    "pub fn release_smoke() -> @react.VirtualNode {\n  @react.table([])\n}\n",
  );

  run("moon", ["update"]);
  const tree = run("moon", ["tree"]);
  if (!tree.includes(`tiye/react@${version}`)) {
    throw new Error(`resolved dependency tree does not contain tiye/react@${version}`);
  }
  run("moon", ["check", "--target", "js"]);
  run("moon", ["build", "--target", "js"]);

  console.log(
    JSON.stringify(
      {
        module: "tiye/react",
        exactVersion: version,
        downstreamCommandsPassed: results.length,
        generatedSmokeNodes: ["table"],
        results,
      },
      null,
      2,
    ),
  );
} finally {
  rmSync(directory, { recursive: true, force: true });
}
