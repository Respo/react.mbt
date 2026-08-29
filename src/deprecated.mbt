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
