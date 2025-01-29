import { h, render } from "preact";
import { useState } from "preact/hooks";

// import { h, render } from "../node_modules/preact/src/index.js";
// import { useState } from "../node_modules/preact/hooks/src/index.js";

function App() {
  let [a, setA] = useState(1);
  return h("div", null, `Hello, Preact! ... ${a}`);
}

render(h(App), document.body);
