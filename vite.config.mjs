import { defineConfig } from "vite";

const normalizeTodoMvcPlaceholder = {
  name: "normalize-todomvc-placeholder-selector",
  enforce: "pre",
  transform(code, id) {
    if (!id.endsWith("/todomvc-app-css/index.css")) return null;
    return {
      code: code.replaceAll("::input-placeholder", "::placeholder"),
      map: null,
    };
  },
};

export default defineConfig({
  // todomvc-app-css@2.4.3 contains one non-standard selector that LightningCSS
  // warns about. Normalize it at build time without modifying or vendoring the
  // CC-BY dependency.
  plugins: [normalizeTodoMvcPlaceholder],
});
