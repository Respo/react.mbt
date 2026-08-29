///|
// React Hooks wrappers, aligned with existing use_state style

using @dom {type JsObscure}

///|
extern "js" fn react_use_effect(
  effect : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> Unit =
  #| (effect, deps) => window.React.useEffect(effect, deps)

///|
extern "js" fn react_use_layout_effect(
  effect : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> Unit =
  #| (effect, deps) => window.React.useLayoutEffect(effect, deps)

///|
extern "js" fn react_use_memo(
  factory : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (factory, deps) => window.React.useMemo(factory, deps)

///|
extern "js" fn react_use_callback(
  callback : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> JsObscure =
  #| (callback, deps) => window.React.useCallback(callback, deps)

///|
extern "js" fn react_use_effect_event(callback : JsObscure) -> JsObscure =
  #| (callback) => window.React.useEffectEvent(callback)

///|
extern "js" fn react_use_action_state(
  action : JsObscure,
  initial : JsObscure,
) -> JsObscure =
  #| (action, initial) => window.React.useActionState(action, initial)

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
extern "js" fn react_use_id() -> String =
  #| () => window.React.useId()

///|
extern "js" fn react_use_deferred_value(value : JsObscure) -> JsObscure =
  #| (value) => window.React.useDeferredValue(value)

///|
extern "js" fn react_use_transition() -> JsObscure =
  #| () => window.React.useTransition()

///|
extern "js" fn react_start_transition(action : JsObscure) -> Unit =
  #| (action) => window.React.startTransition(action)

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
  react_use_layout_effect(
    fn0_to_js_obscure(effect),
    FixedArray::from_array(deps),
  )
}

///|
// useMemo
pub fn[A] use_memo_deps(factory : () -> A, deps : Array[@dom.JsObscure]) -> A {
  let v = react_use_memo(
    @dom.v_to_js_obscure(factory),
    FixedArray::from_array(deps),
  )
  @dom.js_obscure_to_v(v)
}

///|
// useCallback
pub fn[F] use_callback_deps(callback : F, deps : Array[@dom.JsObscure]) -> F {
  let v = react_use_callback(
    @dom.v_to_js_obscure(callback),
    FixedArray::from_array(deps),
  )
  @dom.js_obscure_to_v(v)
}

///|
/// Creates a non-reactive callback for use from an effect. The callback always
/// observes the latest props and state without becoming an effect dependency.
/// React requires effect events to be invoked only from effects.
pub fn[F] use_effect_event(callback : F) -> F {
  let v = react_use_effect_event(@dom.v_to_js_obscure(callback))
  @dom.js_obscure_to_v(v)
}

///|
/// Stores state managed by a React 19 action. The action receives the current
/// MoonBit state and its dispatched value, then returns the next state.
///
/// React reports whether an action transition is pending in the final tuple
/// value. Dispatch from a form action or `start_transition` when appropriate.
pub fn[S, A] use_action_state(
  initial : S,
  action : (S, A) -> S,
) -> (S, (A) -> Unit, Bool) {
  let pair = react_use_action_state(
    @dom.v_to_js_obscure(action),
    any_to_js_value(initial),
  )
  let state : S = any_from_js_value(pair.get("0"))
  let dispatch = fn1_from_js_obscure(pair.get("1"))
  let is_pending : Bool = any_from_js_value(pair.get("2"))
  (state, fn(value : A) { dispatch(any_to_js_value(value)) }, is_pending)
}

///|
// useEffect
pub fn use_effect_once(effect : () -> Unit) -> Unit {
  react_use_effect(fn0_to_js_obscure(effect), FixedArray::from_array([]))
}

///|
/// Runs an effect with dependencies and registers its returned cleanup function.
pub fn use_effect_cleanup_deps(
  effect : () -> () -> Unit,
  deps : Array[@dom.JsObscure],
) -> Unit {
  react_use_effect(@dom.v_to_js_obscure(effect), FixedArray::from_array(deps))
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
  react_use_effect(fn0_to_js_obscure(effect), FixedArray::from_array(deps))
}

///|
/// Runs a layout effect with dependencies and registers its returned cleanup
/// function. Prefer this only when the effect must run before the browser paints.
pub fn use_layout_effect_cleanup_deps(
  effect : () -> () -> Unit,
  deps : Array[@dom.JsObscure],
) -> Unit {
  react_use_layout_effect(
    @dom.v_to_js_obscure(effect),
    FixedArray::from_array(deps),
  )
}

///|
// useCallback (no argument)
pub fn use_callback0_deps(
  f : () -> Unit,
  deps : Array[@dom.JsObscure],
) -> () -> Unit {
  let raw = react_use_callback(
    @dom.v_to_js_obscure(f),
    FixedArray::from_array(deps),
  )
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
/// Returns the underlying React ref object for an explicit JavaScript property,
/// for example `attrs.set_js_value("ref", input_ref.to_js_obscure())`.
pub fn[T] ReactRef::to_js_obscure(self : ReactRef[T]) -> JsObscure {
  self.js_value
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

///|
/// Returns a stable identifier suitable for associating component-local DOM
/// elements, such as a label and its input.
pub fn use_id() -> String {
  react_use_id()
}

///|
/// Defers a value so that urgent updates can render before expensive consumers
/// of that value. The returned value keeps the original MoonBit type.
pub fn[T] use_deferred_value(value : T) -> T {
  react_use_deferred_value(any_to_js_value(value)) |> any_from_js_value
}

///|
/// Marks state updates made by `action` as non-urgent. The returned boolean is
/// true while React is rendering the transition.
pub fn use_transition() -> (Bool, (() -> Unit) -> Unit) {
  let pair = react_use_transition()
  let is_pending : Bool = any_from_js_value(pair.get("0"))
  let start_raw = fn1_from_js_obscure(pair.get("1"))
  (is_pending, fn(action) { start_raw(fn0_to_js_obscure(action)) })
}

///|
/// Marks updates made by `action` as non-urgent without reading transition
/// state. Use `use_transition` when the component also needs `is_pending`.
pub fn start_transition(action : () -> Unit) -> Unit {
  react_start_transition(fn0_to_js_obscure(action))
}
