import * as React from "react";
import * as ReactDOMClient from "react-dom/client";

function App() {
  const [a, setA] = React.useState(1);
  return React.createElement("div", null, `Hello, React! ... ${a}`);
}

const root = ReactDOMClient.createRoot(document.body);
root.render(React.createElement(App));
