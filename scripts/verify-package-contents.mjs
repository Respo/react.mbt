import { createHash } from "node:crypto";
import { readFileSync, statSync } from "node:fs";
import { spawnSync } from "node:child_process";

const expectedFiles = [
  "CHANGELOG.md",
  "LICENSE",
  "README.md",
  "moon.mod",
  "src/alias.mbt",
  "src/components.mbt",
  "src/context.mbt",
  "src/css-in-mbt.mbt",
  "src/deprecated.mbt",
  "src/dom.generated.mbt",
  "src/forms.mbt",
  "src/hooks.mbt",
  "src/moon.pkg",
  "src/pkg.generated.mbti",
  "src/react.mbt",
  "src/react.mjs",
  "src/resources.mbt",
  "src/root.mbt",
];

const result = spawnSync("moon", ["package", "--frozen", "--list"], {
  encoding: "utf8",
});
if (result.status !== 0) {
  process.stderr.write(result.stdout);
  process.stderr.write(result.stderr);
  process.exit(result.status ?? 1);
}

const output = `${result.stdout}${result.stderr}`;
const lines = output.split(/\r?\n/);
const checkPassed = lines.indexOf("Check passed");
const packageLine = lines.findIndex((line) => line.startsWith("Package to "));
if (checkPassed < 0 || packageLine < 0 || packageLine <= checkPassed) {
  console.error("package content check failed: could not parse moon package --list");
  process.exit(1);
}

const actualFiles = lines.slice(checkPassed + 1, packageLine).filter(Boolean);
const missing = expectedFiles.filter((file) => !actualFiles.includes(file));
const unexpected = actualFiles.filter((file) => !expectedFiles.includes(file));
if (missing.length > 0 || unexpected.length > 0) {
  console.error(
    `package content check failed: missing=[${missing.join(", ")}] unexpected=[${unexpected.join(", ")}]`,
  );
  process.exit(1);
}

const archivePath = lines[packageLine].slice("Package to ".length);
const archive = readFileSync(archivePath);
const sha256 = createHash("sha256").update(archive).digest("hex");

console.log(
  JSON.stringify(
    {
      archive: archivePath,
      files: actualFiles.length,
      bytes: statSync(archivePath).size,
      sha256,
      unexpectedFiles: 0,
    },
    null,
    2,
  ),
);
