import { h, render } from "preact";

function App() {
  return h("div", null, "Hello, Preact!");
}

render(h(App), document.body);
