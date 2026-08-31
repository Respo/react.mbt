import * as React from "react";
import * as ReactDOMServer from "react-dom/server";

globalThis.React = React;
globalThis.ReactDOMServer = ReactDOMServer;

const originalWarn = console.warn.bind(console);
const originalError = console.error.bind(console);
globalThis.__moonbitServerDiagnostics = [];
console.warn = (...args) => {
  globalThis.__moonbitServerDiagnostics.push(`warning: ${args.join(" ")}`);
  originalWarn(...args);
};
console.error = (...args) => {
  globalThis.__moonbitServerDiagnostics.push(`error: ${args.join(" ")}`);
  originalError(...args);
};
process.on("beforeExit", () => {
  if (globalThis.__moonbitServerDiagnostics.length > 0) {
    originalError(
      `Unexpected server diagnostics: ${JSON.stringify(globalThis.__moonbitServerDiagnostics)}`,
    );
    process.exitCode = 1;
  }
});
