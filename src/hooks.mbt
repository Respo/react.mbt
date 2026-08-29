///|
// React Hooks wrappers, aligned with existing use_state style

using @dom {type JsObscure}

///|
extern "js" fn react_use_effect(
  effect : @dom.JsObscure,
  deps : Array[@dom.JsObscure],
) -> Unit =
  #| (effect, deps) => window.React.useEffect(effect, deps)

///|
extern "js" fn react_use_layout_effect(
  effect : @dom.JsObscure,
  deps : Array[@dom.JsObscure],
) -> Unit =
  #| (effect, deps) => window.React.useLayoutEffect(effect, deps)

///|
extern "js" fn react_use_memo(
  factory : @dom.JsObscure,
  deps : Array[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (factory, deps) => window.React.useMemo(factory, deps)

///|
extern "js" fn react_use_callback(
  callback : @dom.JsObscure,
  deps : Array[@dom.JsObscure],
) -> JsObscure =
  #| (callback, deps) => window.React.useCallback(callback, deps)

///|
extern "js" fn react_use_ref(initial : @dom.JsObscure) -> @dom.JsObscure =
  #| (initial) => window.React.useRef(initial)

///|
extern "js" fn react_ref_get_value(r : @dom.JsObscure) -> @dom.JsObscure =
  #| (ref) => ref.current

///|
extern "js" fn react_ref_set_value(
  r : @dom.JsObscure,
  value : JsObscure,
) -> Unit =
  #| (ref, value) => ref.current = value

///|
extern "js" fn react_use_reducer(
  reducer : JsObscure,
  initial : JsObscure,
) -> JsObscure =
  #| (reducer, initial) => window.React.useReducer(reducer, initial)

///|
fn fn0_to_js_obscure(f : () -> Unit) -> @dom.JsObscure = "%identity"

///|
fn fn1_from_js_obscure(v : JsObscure) -> (JsObscure) -> Unit = "%identity"

///|
// useLayoutEffect
pub fn use_layout_effect_deps(
  effect : () -> Unit,
  deps : Array[@dom.JsObscure],
) -> Unit {
  react_use_layout_effect(fn0_to_js_obscure(effect), deps)
}

///|
// useMemo
pub fn[A] use_memo_deps(factory : () -> A, deps : Array[@dom.JsObscure]) -> A {
  let v = react_use_memo(@dom.v_to_js_obscure(factory), deps)
  @dom.js_obscure_to_v(v)
}

///|
// useCallback
pub fn[F] use_callback_deps(callback : F, deps : Array[@dom.JsObscure]) -> F {
  let v = react_use_callback(@dom.v_to_js_obscure(callback), deps)
  @dom.js_obscure_to_v(v)
}

///|
// useEffect
pub fn use_effect_once(effect : () -> Unit) -> Unit {
  react_use_effect(fn0_to_js_obscure(effect), [])
}

///|
/// Runs an effect with dependencies and registers its returned cleanup function.
pub fn use_effect_cleanup_deps(
  effect : () -> () -> Unit,
  deps : Array[@dom.JsObscure],
) -> Unit {
  react_use_effect(@dom.v_to_js_obscure(effect), deps)
}

///|
/// Runs an effect once and registers its returned cleanup function.
pub fn use_effect_once_with_cleanup(effect : () -> () -> Unit) -> Unit {
  use_effect_cleanup_deps(effect, [])
}

///|
/// a short hand to turn value into JsObscure in hook deps
pub fn[T] obscure(v : T) -> @dom.JsObscure = "%identity"

///|
pub fn use_effect_deps(
  effect : () -> Unit,
  deps : Array[@dom.JsObscure],
) -> Unit {
  react_use_effect(fn0_to_js_obscure(effect), deps)
}

///|
/// Runs a layout effect with dependencies and registers its returned cleanup
/// function. Prefer this only when the effect must run before the browser paints.
pub fn use_layout_effect_cleanup_deps(
  effect : () -> () -> Unit,
  deps : Array[@dom.JsObscure],
) -> Unit {
  react_use_layout_effect(@dom.v_to_js_obscure(effect), deps)
}

///|
// useCallback (no argument)
pub fn use_callback0_deps(
  f : () -> Unit,
  deps : Array[@dom.JsObscure],
) -> () -> Unit {
  let raw = react_use_callback(@dom.v_to_js_obscure(f), deps)
  @dom.js_obscure_to_v(raw)
}

///|
struct ReactRef[T] {
  js_value : @dom.JsObscure
  mut _v0 : T
}

///|
pub fn[T] ReactRef::from(v : T) -> ReactRef[T] {
  ReactRef::{ js_value: react_use_ref(@dom.v_to_js_obscure(v)), _v0: v }
}

///|
pub fn[T] ReactRef::get(self : ReactRef[T]) -> T {
  @dom.js_obscure_to_v(react_ref_get_value(self.js_value))
}

///|
pub fn[T] ReactRef::set(self : ReactRef[T], value : T) -> Unit {
  react_ref_set_value(self.js_value, any_to_js_value(value))
  self._v0 = value
}

///|
// useRef
pub fn[T] use_ref(initial : T) -> ReactRef[T] {
  ReactRef::{
    js_value: react_use_ref(@dom.v_to_js_obscure(initial)),
    _v0: initial,
  }
}

///|
// useReducer
pub fn[S : Default, A] use_reducer(
  initial? : S,
  reducer : (S, A) -> S,
) -> (S, (A) -> Unit) {
  let pair = react_use_reducer(
    any_to_js_value(reducer),
    any_to_js_value(initial.unwrap_or_default()),
  )
  let s0 = any_from_js_value(pair.get("0"))
  let dispatch_raw = fn1_from_js_obscure(pair.get("1"))
  (s0, fn(a : A) { dispatch_raw(any_to_js_value(a)) })
}
