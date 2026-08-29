# Changelog

## 0.1.0

- Restored compatibility with the current MoonBit manifest format and toolchain.
- Added React root reuse and explicit `unmount` support.
- Added `component_with_children` for components that need to place caller
  children in their rendered tree.
- Added cleanup-capable effect bindings.
- Added React 19-compatible `use_id`, `use_deferred_value`, and transition
  bindings with regression coverage.
- Moved the deprecated `declare_contained_style` compatibility alias into its
  own source file and documented its replacement.
- Added typed boolean and integer element attributes and corrected raw HTML and
  event-handler conversion for React.
- Added `input(checked=...)` for controlled checkbox and radio inputs, keeping
  both boolean values intact.
- Added `DOMEvent::target_checked()` for reading controlled checkbox and radio
  state from form handlers.
- Updated JavaScript FFI array boundaries to MoonBit's `FixedArray` ABI while
  preserving the public `Array`-based hook API.
- Added regression coverage for React element conversion, roots, components,
  props, hooks, styles, events, and built-in element helpers.
- Made browser builds and CI checks reproducible.
- Upgraded the browser runtime to React 19.2 and the build toolchain to Vite 8.

## 0.0.3

Experimental React bindings for MoonBit.
