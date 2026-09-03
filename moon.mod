name = "tiye/react"

version = "0.4.0"

import {
  "tiye/dom-ffi@0.4.0",
  "tiye/respo_css@0.1.7",
  "moonbitlang/async@0.20.3",
}

readme = "README.md"

repository = "https://github.com/Respo/react.mbt"

license = "Apache-2.0"

keywords = [ "react", "binding" ]

description = "Type-safe MoonBit bindings for React with virtual DOM, hooks, and CSS-in-JS support (early experimental)"

source = "src"

preferred_target = "js"

// Keep release archives focused on the consumable library. Migrate these
// gitignore-style rules to `.moonignore` after the pinned moon supports it.

options(
  exclude: [
    "Agents.md",
    "CONTRIBUTING.md",
    "compare.html",
    "index.html",
    "package.json",
    "playwright.config.mjs",
    "release-notes",
    "release-tags.json",
    "scripts",
    "tests",
    "vite.config.mjs",
    "yarn.lock",
    "*_test.mbt",
    "*_wbtest.mbt",
    "src/demo.mjs",
    "src/main",
  ],
)
