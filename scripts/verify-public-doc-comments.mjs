import { readFileSync } from "node:fs";

const source = readFileSync(new URL("../src/root.mbt", import.meta.url), "utf8");
const declarations = [
  "pub(all) enum ResourceCrossOrigin",
  "pub(all) enum ResourceFetchPriority",
  "pub(all) enum PreloadDestination",
  "pub(all) enum ResourceReferrerPolicy",
  "pub(all) enum ResourceStylePrecedence",
  "struct PreloadOptions",
  "pub fn PreloadOptions::new",
  "struct ModuleHintOptions",
  "pub fn ModuleHintOptions::new",
  "struct PreinitOptions",
  "pub fn PreinitOptions::script",
  "pub fn PreinitOptions::style",
  "pub fn flush_sync",
  "pub fn prefetch_dns",
  "pub fn preconnect",
  "pub fn preload",
  "pub fn preload_module",
  "pub fn preinit",
  "pub fn preinit_module",
];

const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const matchesDeclaration = (block, declaration) =>
  new RegExp(`${escapeRegExp(declaration)}(?=\\s*[({])`, "m").test(block);

const prefixCollisionRegressions = [
  ["pub fn preload_module(String) -> Unit", "pub fn preload"],
  ["pub fn preinit_module(String) -> Unit", "pub fn preinit"],
];
for (const [block, shorterDeclaration] of prefixCollisionRegressions) {
  if (matchesDeclaration(block, shorterDeclaration)) {
    console.error(
      `public API doc-comment checker matched a declaration prefix: ${shorterDeclaration}`,
    );
    process.exit(1);
  }
}

const blocks = source.split("///|");
const missing = declarations.filter((declaration) => {
  const block = blocks.find((candidate) =>
    matchesDeclaration(candidate, declaration),
  );
  if (!block) return true;
  const declarationOffset = block.indexOf(declaration);
  return !block
    .slice(0, declarationOffset)
    .split("\n")
    .some((line) => /^\s*\/\/\/\s+\S/.test(line));
});

if (missing.length > 0) {
  console.error(
    `public API doc-comment check failed: ${missing.join(", ")}`,
  );
  process.exit(1);
}

console.log(
  JSON.stringify(
    {
      documentedDeclarations: declarations.length,
      missingDocComments: 0,
      prefixCollisionRegressions: prefixCollisionRegressions.length,
    },
    null,
    2,
  ),
);
