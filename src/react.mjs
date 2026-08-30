import * as React from "react";
import * as ReactDOM from "react-dom";
import * as ReactDOMClient from "react-dom/client";
// 导入官方 TodoMVC CSS
import "todomvc-app-css/index.css";

window.React = React;
window.ReactDOM = ReactDOM;
window.ReactDOMClient = ReactDOMClient;

// Keep the server renderer in a separate demo chunk, then start MoonBit only
// after every global required by the conformance fixtures is ready.
window.ReactDOMServer = await import("react-dom/server.browser");
await import("../_build/js/debug/build/main/main.js");
