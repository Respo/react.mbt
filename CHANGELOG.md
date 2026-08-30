# Changelog

## Unreleased

- Added `create_portal` with real React coverage for target placement,
  React-tree event propagation, and cleanup when the owning root unmounts.
- Added typed React 19 root options for `identifierPrefix`, caught, uncaught,
  and recoverable error callbacks, including error message and component-stack
  accessors.
- Added basic synchronous `render_to_string` SSR/SSG and `hydrate_root`, with
  browser conformance for node reuse, matching `use_id` prefixes, interactive
  hydration, and zero mismatches on the supported path. Streaming, suspended
  data, and React Server Components remain explicitly out of scope.
- Switched the library FFI to `globalThis` React globals so synchronous server
  rendering does not require a browser `window` shim.
- Added typed React 19 form `action` and submit-control `formAction` props,
  `ReactFormData`, and MoonBit async-to-Promise Action interoperation.
- Added `use_optimistic` and ReactDOM `use_form_status` bindings with real
  React coverage for deterministic pending transitions, successful settle,
  failure rollback, submitted data, and zero unhandled rejections.
- Deduplicated React and ReactDOM resolution in Vite so DOM Hooks share the
  renderer dispatcher during development and browser tests.
- Stabilized `component` and `component_with_children` React factory identity so
  repeated root renders update components without remounting them.
- Added real React 19.2.8 conformance coverage for StrictMode lifecycle,
  functional state and reducer batching, root reuse and unmount, DOM ref mount
  and cleanup, and warning-free execution.
- Added `use_dom_ref` and `ReactDomRef` with an explicit `Element?` lifecycle,
  and deprecated the constructor-shaped `ReactRef::from` Hook alias.
- Added typed uncontrolled form defaults; the shared conversion boundary now
  rejects controlled/uncontrolled conflicts, controlled fields without change
  handling, invalid select value shapes, and children combined with `innerHTML`.
- Removed the unsupported `selected` option helper; selection now belongs on
  `select` through scalar or multiple-value props.
- Added typed React Context creation, provider, consumption, and JavaScript
  interoperation with nested-provider browser coverage.
- Added `VirtualNode::with_key` for stable reconciliation identity across
  elements, components, fragments, and text, and made browser regressions fail
  on React console warnings and errors.
- Made `static_style` and `contained_static_style` safe to evaluate without a
  browser `window`, enabling server-side and pre-rendered module imports.
- Added stateful MoonBit component regressions for Todo editing, creation,
  filtering, hooks, and application bootstrap, plus a Chromium TodoMVC smoke
  test in CI.
- Completed the demo's controlled toggle-all flow and made its filters real,
  keyboard-accessible links without changing client-side navigation.
- Added the React 19.2 `use_effect_event` binding for non-reactive callbacks
  invoked from effects.
- Added a typed React 19 `use_action_state` binding for stateful actions and
  pending-state reporting.
- Added `use_reducer_with_initial`, removing the unnecessary `Default`
  constraint for reducer state in new code.
- Normalized TodoMVC's legacy placeholder selector during Vite builds, removing
  the third-party LightningCSS warning without modifying the dependency.

## 0.1.0

- Restored compatibility with the current MoonBit manifest format and toolchain.
- Added React root reuse and explicit `unmount` support.
- Added `component_with_children` for components that need to place caller
  children in their rendered tree.
- Added cleanup-capable effect bindings.
- Added React 19-compatible `use_id`, `use_deferred_value`, and transition
  bindings with regression coverage.
- Added `use_state_with_updater` and typed `StateUpdate` values for functional
  state updates that safely derive from React's latest state.
- Made `ReactRef` usable on virtual elements through `to_js_obscure()` and the
  explicit `ElementAttrs::set_js_value` bridge.
- Moved the deprecated `declare_contained_style` compatibility alias into its
  own source file and documented its replacement.
- Added typed boolean and integer element attributes and corrected raw HTML and
  event-handler conversion for React.
- Added `input(checked=...)` for controlled checkbox and radio inputs, keeping
  both boolean values intact.
- Added `DOMEvent::target_checked()` for reading controlled checkbox and radio
  state from form handlers.
- Extended typed event bindings with clipboard, composition, pointer, wheel,
  animation, transition, `beforeinput`, `invalid`, and `toggle` events.
- Documented API stability, the `JsObscure` interoperation boundary, global
  React setup, and the required component lifecycle wrapper.
- Updated the Quick Start snippet to current MoonBit default, float, and CSS
  constructor syntax.
- Removed unconditional browser-entry and TodoMVC rerender debug logs.
- Updated JavaScript FFI array boundaries to MoonBit's `FixedArray` ABI while
  preserving the public `Array`-based hook API.
- Added regression coverage for React element conversion, roots, components,
  props, hooks, styles, events, and built-in element helpers.
- Made browser builds and CI checks reproducible.
- Upgraded the browser runtime to React 19.2 and the build toolchain to Vite 8.

## 0.0.3

Experimental React bindings for MoonBit.
