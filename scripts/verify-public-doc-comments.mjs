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

const blocks = source.split("///|");
const missing = declarations.filter((declaration) => {
  const block = blocks.find((candidate) => candidate.includes(declaration));
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
    },
    null,
    2,
  ),
);
