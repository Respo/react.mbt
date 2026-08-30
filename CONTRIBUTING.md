# Contributing

## 中文

### 重新生成 DOM helpers

不要直接编辑 `src/dom.generated.mbt` 或 `src/dom_generated_wbtest.mbt`。
元素、属性和事件的声明式数据位于 `scripts/dom-elements.mjs`，生成逻辑位于
`scripts/generate-dom-helpers.mjs`。

```sh
corepack yarn generate:dom
corepack yarn check:generated
moon info
moon fmt
moon check --target js
moon test --target js
corepack yarn test:browser
corepack yarn build
git diff --check
```

`generate:dom` 写入并格式化生成源码与全量 smoke matrix；`check:generated`
再次生成并在输出发生变化时失败。连续运行两次后，第二次必须不产生 Git
diff。`moon info` 更新的 `.mbti` 文件必须一并提交，CI 会验证生成源码和公开
接口均未过期。

新增元素时请为 table、form、interactive、metadata、semantic 或 SVG 选择明确
类别，并声明 React 使用的 camelCase prop 名。常见 `aria-*`、`data-*` 和自定义
元素仍可通过 `ElementAttrs` 与 `create_element` escape hatch 表达。

---

## English

### Regenerating DOM helpers

Do not edit `src/dom.generated.mbt` or `src/dom_generated_wbtest.mbt` directly.
The declarative element, prop, and event data lives in
`scripts/dom-elements.mjs`; generation logic lives in
`scripts/generate-dom-helpers.mjs`.

```sh
corepack yarn generate:dom
corepack yarn check:generated
moon info
moon fmt
moon check --target js
moon test --target js
corepack yarn test:browser
corepack yarn build
git diff --check
```

`generate:dom` writes and formats the generated source and all-helper smoke
matrix. `check:generated` regenerates them and fails when the output changes.
After two consecutive runs, the second run must leave no Git diff. Commit the
`.mbti` files updated by `moon info`; CI checks that both generated source and
public interfaces are current.

When adding an element, assign it to the table, form, interactive, metadata,
semantic, or SVG category and declare the React camel-case prop names. General
`aria-*`, `data-*`, and custom-element needs remain available through the
`ElementAttrs` and `create_element` escape hatches.
