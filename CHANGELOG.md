# Changelog

## 0.1.0

- Restored compatibility with the current MoonBit manifest format and toolchain.
- Added React root reuse and explicit `unmount` support.
- Added `component_with_children` for components that need to place caller
  children in their rendered tree.
- Added cleanup-capable effect bindings.
- Added typed boolean and integer element attributes and corrected raw HTML and
  event-handler conversion for React.
- Updated JavaScript FFI array boundaries to MoonBit's `FixedArray` ABI while
  preserving the public `Array`-based hook API.
- Added regression coverage for React element conversion, roots, components,
  props, hooks, styles, events, and built-in element helpers.
- Made browser builds and CI checks reproducible.

## 0.0.3

Experimental React bindings for MoonBit.
