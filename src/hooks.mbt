///|
// Preact Hooks wrappers, aligned with existing use_state style

///|
extern "js" fn preact_use_effect(effect : JsValue, deps : JsValue) -> Unit =
  #| (effect, deps) => window.PreactHooks.useEffect(effect, deps)

///|
extern "js" fn preact_use_layout_effect(
  effect : JsValue,
  deps : JsValue,
) -> Unit =
  #| (effect, deps) => window.PreactHooks.useLayoutEffect(effect, deps)

///|
extern "js" fn preact_use_memo(factory : JsValue, deps : JsValue) -> JsValue =
  #| (factory, deps) => window.PreactHooks.useMemo(factory, deps)

///|
extern "js" fn preact_use_callback(
  callback : JsValue,
  deps : JsValue,
) -> JsValue =
  #| (callback, deps) => window.PreactHooks.useCallback(callback, deps)

///|
extern "js" fn preact_use_ref(initial : JsValue) -> JsValue =
  #| (initial) => window.PreactHooks.useRef(initial)

///|
extern "js" fn preact_ref_get_value(r : JsValue) -> JsValue =
  #| (ref) => ref.current

///|
extern "js" fn preact_ref_set_value(r : JsValue, value : JsValue) -> Unit =
  #| (ref, value) => ref.current = value

///|
extern "js" fn preact_use_reducer(
  reducer : JsValue,
  initial : JsValue,
) -> JsValue =
  #| (reducer, initial) => window.PreactHooks.useReducer(reducer, initial)

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
fn[A, B, C, D, E, F, G, H] deps_to_js_array(
  deps : Deps[A, B, C, D, E, F, G, H],
) -> JsArray {
  let arr = JsArray::new()
  match deps {
    Dep0 => ()
    Dep1(a) => arr.push(any_to_js_value(a))
    Dep2(a, b) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
    }
    Dep3(a, b, c) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
      arr.push(any_to_js_value(c))
    }
    Dep4(a, b, c, d) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
      arr.push(any_to_js_value(c))
      arr.push(any_to_js_value(d))
    }
    Dep5(a, b, c, d, e) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
      arr.push(any_to_js_value(c))
      arr.push(any_to_js_value(d))
      arr.push(any_to_js_value(e))
    }
    Dep6(a, b, c, d, e, f) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
      arr.push(any_to_js_value(c))
      arr.push(any_to_js_value(d))
      arr.push(any_to_js_value(e))
      arr.push(any_to_js_value(f))
    }
    Dep7(a, b, c, d, e, f, g) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
      arr.push(any_to_js_value(c))
      arr.push(any_to_js_value(d))
      arr.push(any_to_js_value(e))
      arr.push(any_to_js_value(f))
      arr.push(any_to_js_value(g))
    }
    Dep8(a, b, c, d, e, f, g, h) => {
      arr.push(any_to_js_value(a))
      arr.push(any_to_js_value(b))
      arr.push(any_to_js_value(c))
      arr.push(any_to_js_value(d))
      arr.push(any_to_js_value(e))
      arr.push(any_to_js_value(f))
      arr.push(any_to_js_value(g))
      arr.push(any_to_js_value(h))
    }
  }
  arr
}

///|
// useEffect
pub fn use_effect_once(effect : () -> Unit) -> Unit {
  preact_use_effect(any_to_js_value(effect), JsArray::new().to_value())
}

///|
pub fn[A, B, C, D, E, F, G, H] use_effect_deps(
  effect : () -> Unit,
  deps : Deps[A, B, C, D, E, F, G, H],
) -> Unit {
  preact_use_effect(any_to_js_value(effect), deps_to_js_array(deps).to_value())
}

///|
// useLayoutEffect
pub fn[A, B, C, D, E, F, G, H] use_layout_effect_deps(
  effect : () -> Unit,
  deps : Deps[A, B, C, D, E, F, G, H],
) -> Unit {
  preact_use_layout_effect(
    any_to_js_value(effect),
    deps_to_js_array(deps).to_value(),
  )
}

///|
// useMemo
pub fn[T : JsValueTrait, A, B, C, D, E, F, G, H] use_memo_deps(
  factory : () -> T,
  deps : Deps[A, B, C, D, E, F, G, H],
) -> T {
  let r = preact_use_memo(
    any_to_js_value(factory),
    deps_to_js_array(deps).to_value(),
  )
  T::from_value(r)
}

///|
// useCallback (with one argument)
pub fn[V, A, B, C, D, E, F, G, H] use_callback_deps(
  f : V,
  deps : Deps[A, B, C, D, E, F, G, H],
) -> (A) -> Unit {
  let raw = preact_use_callback(
    any_to_js_value(f),
    deps_to_js_array(deps).to_value(),
  )
  let cb = fn1_from_value(raw)
  fn(a : A) { cb(any_to_js_value(a)) }
}

///|
// useCallback (no argument)
pub fn[A, B, C, D, E, F, G, H] use_callback0_deps(
  f : () -> Unit,
  deps : Deps[A, B, C, D, E, F, G, H],
) -> () -> Unit {
  let raw = preact_use_callback(
    any_to_js_value(f),
    deps_to_js_array(deps).to_value(),
  )
  fn0_from_value(raw)
}

///|
struct PreactRef[T] {
  /// value passed to Preact
  js_value : JsValue
  /// bookkeeping value, not to be used directly
  mut _v0 : T
}

///|
pub fn[T] PreactRef::from(v : T) -> PreactRef[T] {
  PreactRef::{ js_value: preact_use_ref(any_to_js_value(v)), _v0: v }
}

///|
pub fn[T] PreactRef::get(self : PreactRef[T]) -> T {
  any_from_js_value(preact_ref_get_value(self.js_value))
}

///|
pub fn[T] PreactRef::set(self : PreactRef[T], value : T) -> Unit {
  preact_ref_set_value(self.js_value, any_to_js_value(value))
  self._v0 = value
}

///|
// useRef
pub fn[T : JsValueTrait] use_ref(initial : T) -> PreactRef[T] {
  PreactRef::{ js_value: preact_use_ref(initial.to_value()), _v0: initial }
}

///|
// useReducer
pub fn[S : JsValueTrait, A : JsValueTrait] use_reducer(
  initial : S,
  reducer : (S, A) -> S,
) -> (S, (A) -> Unit) {
  let pair = preact_use_reducer(any_to_js_value(reducer), initial.to_value()).to_array()
  let s0 = S::from_value(pair[0])
  let dispatch_raw = fn1_from_value(pair[1])
  (s0, fn(a : A) { dispatch_raw(a.to_value()) })
}
