///|
// React Hooks wrappers, aligned with existing use_state style

///|
extern "js" fn react_use_effect(effect : JsValue, deps : JsValue) -> Unit =
  #| (effect, deps) => window.React.useEffect(effect, deps)

///|
extern "js" fn react_use_layout_effect(
  effect : JsValue,
  deps : JsValue,
) -> Unit =
  #| (effect, deps) => window.React.useLayoutEffect(effect, deps)

///|
extern "js" fn react_use_memo(factory : JsValue, deps : JsValue) -> JsValue =
  #| (factory, deps) => window.React.useMemo(factory, deps)

///|
extern "js" fn react_use_callback(
  callback : JsValue,
  deps : JsValue,
) -> JsValue =
  #| (callback, deps) => window.React.useCallback(callback, deps)

///|
extern "js" fn react_use_ref(initial : JsValue) -> JsValue =
  #| (initial) => window.React.useRef(initial)

///|
extern "js" fn react_ref_get_value(r : JsValue) -> JsValue =
  #| (ref) => ref.current

///|
extern "js" fn react_ref_set_value(r : JsValue, value : JsValue) -> Unit =
  #| (ref, value) => ref.current = value

///|
extern "js" fn react_use_reducer(
  reducer : JsValue,
  initial : JsValue,
) -> JsValue =
  #| (reducer, initial) => window.React.useReducer(reducer, initial)

///|
extern "js" fn fn0_from_value(v : JsValue) -> () -> Unit =
  #| (v) => v

///|
extern "js" fn fn1_from_value(v : JsValue) -> (JsValue) -> Unit =
  #| (v) => v

///|
/// 最多支持 8 个依赖项
pub(all) enum Deps[A, B, C, D, E, F, G, H] {
  Dep0
  Dep1(A)
  Dep2(A, B)
  Dep3(A, B, C)
  Dep4(A, B, C, D)
  Dep5(A, B, C, D, E)
  Dep6(A, B, C, D, E, F)
  Dep7(A, B, C, D, E, F, G)
  Dep8(A, B, C, D, E, F, G, H)
}

///|
fn deps_to_js_array(deps : Array[JsValue]) -> JsValue {
  let arr = JsArray::new()
  for d in deps {
    arr.push(d)
  }
  arr.to_value()
}

///|
// useLayoutEffect
pub fn use_layout_effect_deps(
  effect : () -> Unit,
  deps : Array[JsValue],
) -> Unit {
  react_use_layout_effect(any_to_js_value(effect), deps_to_js_array(deps))
}

///|
// useMemo
pub fn[A] use_memo_deps(factory : () -> A, deps : Array[JsValue]) -> A {
  let v = react_use_memo(any_to_js_value(factory), deps_to_js_array(deps))
  any_from_js_value(v)
}

///|
// useCallback
pub fn[F] use_callback_deps(callback : F, deps : Array[JsValue]) -> F {
  let v = react_use_callback(any_to_js_value(callback), deps_to_js_array(deps))
  any_from_js_value(v)
}

///|
// useEffect
pub fn use_effect_once(effect : () -> Unit) -> Unit {
  react_use_effect(any_to_js_value(effect), JsArray::new().to_value())
}

///|
/// a short hand to turn value into JsValue in hook deps
pub fn[T] obscure(v : T) -> JsValue = "%identity"

///|
pub fn use_effect_deps(effect : () -> Unit, deps : Array[JsValue]) -> Unit {
  react_use_effect(any_to_js_value(effect), deps_to_js_array(deps))
}

///|
// useCallback (no argument)
pub fn use_callback0_deps(f : () -> Unit, deps : Array[JsValue]) -> () -> Unit {
  let raw = react_use_callback(any_to_js_value(f), deps_to_js_array(deps))
  fn0_from_value(raw)
}

///|
struct ReactRef[T] {
  js_value : JsValue
  mut _v0 : T
}

///|
pub fn[T] ReactRef::from(v : T) -> ReactRef[T] {
  ReactRef::{ js_value: react_use_ref(any_to_js_value(v)), _v0: v }
}

///|
pub fn[T] ReactRef::get(self : ReactRef[T]) -> T {
  any_from_js_value(react_ref_get_value(self.js_value))
}

///|
pub fn[T] ReactRef::set(self : ReactRef[T], value : T) -> Unit {
  react_ref_set_value(self.js_value, any_to_js_value(value))
  self._v0 = value
}

///|
// useRef
pub fn[T : JsValueTrait] use_ref(initial : T) -> ReactRef[T] {
  ReactRef::{ js_value: react_use_ref(initial.to_value()), _v0: initial }
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
  ).to_array()
  let s0 = any_from_js_value(pair[0])
  let dispatch_raw = fn1_from_value(pair[1])
  (s0, fn(a : A) { dispatch_raw(any_to_js_value(a)) })
}
