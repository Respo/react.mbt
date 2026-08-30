///|
/// Deprecated compatibility alias for `contained_static_style`.
///
/// Use `contained_static_style` in new code. This alias remains available for
/// existing callers and will be removed only in a future breaking release.
#callsite(autofill(loc))
#deprecated
pub fn[U : Show] declare_contained_style(
  rules : Array[(String?, U, RespoStyle)],
  loc~ : SourceLoc,
) -> String {
  contained_static_style(rules, loc~)
}

///|
/// Deprecated Hook-shaped constructor for `ReactRef`.
///
/// Despite its constructor-like name, this calls React `useRef` and therefore
/// must only run at the top level of a component or another Hook. Use
/// `use_ref(initial)` instead, or `use_dom_ref()` for nullable DOM refs.
#deprecated
pub fn[T] ReactRef::from(initial : T) -> ReactRef[T] {
  use_ref(initial)
}
