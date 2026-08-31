import { readFileSync, readdirSync } from "node:fs";
import { basename, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = resolve(fileURLToPath(new URL("..", import.meta.url)));
const sourceDirectory = resolve(repositoryRoot, "src");

// Public declarations can contain generic constraints and JavaScript extern
// bridges before the declaration name. Keep the matcher anchored to a line so
// references to declarations in comments and function bodies are ignored.
const publicDeclarationPattern =
  /^\s*pub(?:\(all\))?\s+(?:(?:async\s+)?fn(?:\[[^\]\n]*\])?|extern\s+"[^"]+"\s+fn|type|struct|enum|trait)\s+([^\s({=]+)/gm;
const docCommentPattern = /^\s*\/\/\/\s+\S/m;

function publicSourceFiles() {
  return readdirSync(sourceDirectory, { withFileTypes: true })
    .filter(
      (entry) =>
        entry.isFile() &&
        entry.name.endsWith(".mbt") &&
        !entry.name.endsWith("_test.mbt") &&
        !entry.name.endsWith("_wbtest.mbt"),
    )
    .map((entry) => resolve(sourceDirectory, entry.name))
    .sort();
}

function declarationKind(declarationText) {
  if (/\bextern\s+"[^"]+"\s+fn\b/.test(declarationText)) return "extern fn";
  if (/\bfn(?:\[|\s)/.test(declarationText)) return "fn";
  for (const kind of ["type", "struct", "enum", "trait"]) {
    if (new RegExp(`\\b${kind}\\b`).test(declarationText)) return kind;
  }
  return "unknown";
}

function analyzeSource(source, file) {
  const declarations = [];
  let blockStart = 0;
  for (const block of source.split("///|")) {
    const blockLine = source.slice(0, blockStart).split("\n").length;
    for (const match of block.matchAll(publicDeclarationPattern)) {
      const declarationOffset = match.index ?? 0;
      const declarationText = match[0].trim();
      const line = blockLine + block.slice(0, declarationOffset).split("\n").length - 1;
      declarations.push({
        file,
        line,
        name: match[1],
        kind: declarationKind(declarationText),
        declaration: declarationText,
        documented: docCommentPattern.test(block.slice(0, declarationOffset)),
      });
    }
    blockStart += block.length + "///|".length;
  }
  return declarations;
}

function runCheckerRegressions() {
  const fixture = `///|
/// Loads a resource.
pub fn preload(url : String) -> Unit { ignore(url) }

///|
pub fn preload_module(url : String) -> Unit { ignore(url) }

///|
/// Converts an external event.
pub extern "js" fn DOMEvent::target_value(self : DOMEvent) -> String =
  #| (event) => event.target.value

///|
/// A generic component factory.
pub fn[T : Show] define_component(render : (T) -> Unit) -> Unit { ignore(render) }
`;
  const declarations = analyzeSource(fixture, "<checker-fixture>");
  const missing = declarations.filter((declaration) => !declaration.documented);
  const names = declarations.map((declaration) => declaration.name);
  if (
    declarations.length !== 4 ||
    missing.length !== 1 ||
    missing[0].name !== "preload_module" ||
    !names.includes("preload") ||
    !names.includes("DOMEvent::target_value") ||
    !names.includes("define_component")
  ) {
    console.error("public API doc-comment checker regressions failed");
    console.error(JSON.stringify(declarations, null, 2));
    process.exit(1);
  }
  return {
    negativeFixtureDetected: missing.length,
    prefixCollisionRegressions: 1,
    genericDeclarationRegressions: 1,
    externDeclarationRegressions: 1,
  };
}

const regressions = runCheckerRegressions();
const sourceFiles = publicSourceFiles();
const declarations = sourceFiles.flatMap((file) =>
  analyzeSource(readFileSync(file, "utf8"), basename(file)),
);
const missing = declarations.filter((declaration) => !declaration.documented);
const byKind = Object.fromEntries(
  [...new Set(declarations.map((declaration) => declaration.kind))]
    .sort()
    .map((kind) => [
      kind,
      declarations.filter((declaration) => declaration.kind === kind).length,
    ]),
);

if (missing.length > 0) {
  console.error(
    `public API doc-comment check failed: ${missing.length}/${declarations.length} declarations are undocumented`,
  );
  for (const declaration of missing) {
    console.error(
      `- ${declaration.file}:${declaration.line} ${declaration.declaration}`,
    );
  }
  process.exit(1);
}

console.log(
  JSON.stringify(
    {
      sourceFiles: sourceFiles.length,
      publicDeclarations: declarations.length,
      documentedDeclarations: declarations.length - missing.length,
      missingDocComments: missing.length,
      byKind,
      ...regressions,
    },
    null,
    2,
  ),
);
