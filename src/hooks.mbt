///|
// React Hooks wrappers, aligned with existing use_state style

using @dom {type JsObscure}

///|
extern "js" fn react_use_effect(
  effect : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> Unit =
  #| (effect, deps) => globalThis.React.useEffect(effect, deps)

///|
extern "js" fn react_use_layout_effect(
  effect : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> Unit =
  #| (effect, deps) => globalThis.React.useLayoutEffect(effect, deps)

///|
extern "js" fn react_use_memo(
  factory : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (factory, deps) => globalThis.React.useMemo(factory, deps)

///|
extern "js" fn react_use_callback(
  callback : @dom.JsObscure,
  deps : FixedArray[@dom.JsObscure],
) -> JsObscure =
  #| (callback, deps) => globalThis.React.useCallback(callback, deps)

///|
extern "js" fn react_use_effect_event(callback : JsObscure) -> JsObscure =
  #| (callback) => globalThis.React.useEffectEvent(callback)

///|
extern "js" fn react_use_action_state(
  action : JsObscure,
  initial : JsObscure,
) -> JsObscure =
  #| (action, initial) => globalThis.React.useActionState(action, initial)

///|
extern "js" fn react_use_ref(initial : @dom.JsObscure) -> @dom.JsObscure =
  #| (initial) => globalThis.React.useRef(initial)

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
  #| (reducer, initial) => globalThis.React.useReducer(reducer, initial)

///|
extern "js" fn react_use_id() -> String =
  #| () => globalThis.React.useId()

///|
extern "js" fn react_use_deferred_value(value : JsObscure) -> JsObscure =
  #| (value) => globalThis.React.useDeferredValue(value)

///|
extern "js" fn react_use_transition() -> JsObscure =
  #| () => globalThis.React.useTransition()

///|
extern "js" fn react_start_transition(action : JsObscure) -> Unit =
  #| (action) => globalThis.React.startTransition(action)

///|
extern "js" fn react_use_sync_external_store(
  subscribe : JsObscure,
  get_snapshot : JsObscure,
  get_server_snapshot : JsObscure,
) -> JsObscure =
  #| (subscribe, getSnapshot, getServerSnapshot) =>
  #|   globalThis.React.useSyncExternalStore(
  #|     subscribe,
  #|     getSnapshot,
  #|     getServerSnapshot ?? undefined,
  #|   )

///|
extern "js" fn react_use_imperative_handle(
  handle_ref : JsObscure,
  create_handle : JsObscure,
  deps : FixedArray[JsObscure],
) -> Unit =
  #| (ref, createHandle, deps) =>
  #|   globalThis.React.useImperativeHandle(ref, createHandle, deps)

///|
fn fn0_to_js_obscure(f : () -> Unit) -> @dom.JsObscure = "%identity"

///|
fn fn1_from_js_obscure(v : JsObscure) -> (JsObscure) -> Unit = "%identity"

///|
/// Runs a layout effect after React mutates the DOM and before the browser
/// paints. Use `obscure` to construct dependencies that are not already
/// `JsObscure` values.
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
/// Memoizes the value returned by `factory` until one of `deps` changes.
///
/// Treat this as a performance optimization rather than a semantic guarantee.
pub fn[A] use_memo_deps(factory : () -> A, deps : Array[@dom.JsObscure]) -> A {
  let v = react_use_memo(
    @dom.v_to_js_obscure(factory),
    FixedArray::from_array(deps),
  )
  @dom.js_obscure_to_v(v)
}

///|
/// Preserves `callback` identity until one of `deps` changes.
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
/// Runs an effect after the component mounts and does not rerun it for later
/// renders. Use `use_effect_once_with_cleanup` when cleanup is required.
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
/// Runs an effect after rendering whenever one of `deps` changes.
///
/// Use `use_effect_cleanup_deps` when the effect owns subscriptions or other
/// resources that must be released.
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
/// Preserves the identity of a zero-argument callback until one of `deps`
/// changes.
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
/// Returns the current value stored in this React ref.
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
/// Replaces the current value stored in this React ref.
pub fn[T] ReactRef::set(self : ReactRef[T], value : T) -> Unit {
  react_ref_set_value(self.js_value, any_to_js_value(value))
  self._v0 = value
}

///|
/// Creates a React ref Hook with an explicit initial value.
///
/// Call this only at the top level of a React component or another Hook. For a
/// DOM element ref with a safe empty state, prefer `use_dom_ref`.
pub fn[T] use_ref(initial : T) -> ReactRef[T] {
  ReactRef::{
    js_value: react_use_ref(@dom.v_to_js_obscure(initial)),
    _v0: initial,
  }
}

///|
/// A DOM element ref whose current value is absent before mount and after
/// unmount. Attach it with `ElementAttrs::set_js_value("ref", ref.to_js_obscure())`.
struct ReactDomRef {
  js_value : @dom.JsObscure
}

///|
/// Creates a nullable DOM ref Hook.
///
/// Call this only at the top level of a React component or another Hook.
pub fn use_dom_ref() -> ReactDomRef {
  ReactDomRef::{ js_value: react_use_ref(JsObscure::null()) }
}

///|
/// Returns the mounted DOM element, or `None` before mount and after unmount.
pub fn ReactDomRef::current(self : ReactDomRef) -> @dom.Element? {
  let current = react_ref_get_value(self.js_value)
  if current.is_nil() {
    None
  } else {
    Some(@dom.js_obscure_to_v(current))
  }
}

///|
/// Returns the underlying React ref object for an explicit `ref` prop.
pub fn ReactDomRef::to_js_obscure(self : ReactDomRef) -> JsObscure {
  self.js_value
}

///|
/// A nullable typed ref for a custom imperative component handle.
struct ImperativeRef[T] {
  js_value : @dom.JsObscure
  _handle_marker : T?
}

///|
/// Creates an empty typed imperative ref. Pass it through typed component props
/// and bind it inside the child with `use_imperative_handle_deps`.
pub fn[T] use_imperative_ref() -> ImperativeRef[T] {
  ImperativeRef::{
    js_value: react_use_ref(JsObscure::null()),
    _handle_marker: None,
  }
}

///|
/// Returns the committed handle, or `None` before mount and after cleanup.
pub fn[T] ImperativeRef::current(self : ImperativeRef[T]) -> T? {
  let current = react_ref_get_value(self.js_value)
  if current.is_nil() {
    None
  } else {
    Some(@dom.js_obscure_to_v(current))
  }
}

///|
/// Returns the underlying React ref object for an explicit JavaScript bridge.
pub fn[T] ImperativeRef::to_js_obscure(self : ImperativeRef[T]) -> JsObscure {
  self.js_value
}

///|
/// Creates a reducer with an explicit initial state. Unlike the compatibility
/// `use_reducer` overload, this accepts state types that do not implement
/// `Default`.
pub fn[S, A] use_reducer_with_initial(
  initial : S,
  reducer : (S, A) -> S,
) -> (S, (A) -> Unit) {
  let pair = react_use_reducer(
    any_to_js_value(reducer),
    any_to_js_value(initial),
  )
  let s0 = any_from_js_value(pair.get("0"))
  let dispatch_raw = fn1_from_js_obscure(pair.get("1"))
  (s0, fn(a : A) { dispatch_raw(any_to_js_value(a)) })
}

///|
/// Compatibility reducer helper with an optional initial state. Prefer
/// `use_reducer_with_initial` for new code so the state type need not derive
/// `Default`.
pub fn[S : Default, A] use_reducer(
  initial? : S,
  reducer : (S, A) -> S,
) -> (S, (A) -> Unit) {
  use_reducer_with_initial(initial.unwrap_or_default(), reducer)
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

///|
/// Reads and subscribes to a typed immutable snapshot from an external store.
///
/// `subscribe` must return an unsubscribe callback and should keep stable
/// identity across renders. Repeated `get_snapshot` calls must return the same
/// value while the store has not changed. Supply `get_server_snapshot` when the
/// component can render on the server; its initial value must also match during
/// hydration.
pub fn[T] use_sync_external_store(
  subscribe : (() -> Unit) -> () -> Unit,
  get_snapshot : () -> T,
  get_server_snapshot? : () -> T,
) -> T {
  let server_snapshot = match get_server_snapshot {
    Some(callback) => @dom.v_to_js_obscure(callback)
    None => JsObscure::null()
  }
  react_use_sync_external_store(
    @dom.v_to_js_obscure(subscribe),
    @dom.v_to_js_obscure(get_snapshot),
    server_snapshot,
  )
  |> any_from_js_value
}

///|
/// Exposes a typed imperative handle through a nullable imperative ref.
///
/// React assigns `Some(handle)` after commit and restores `None` on cleanup.
/// In React 19 the ref can be carried in ordinary typed component props, so a
/// `forwardRef` wrapper is not required.
pub fn[T] use_imperative_handle_deps(
  handle_ref : ImperativeRef[T],
  create_handle : () -> T,
  deps : Array[JsObscure],
) -> Unit {
  react_use_imperative_handle(
    handle_ref.to_js_obscure(),
    @dom.v_to_js_obscure(create_handle),
    FixedArray::from_array(deps),
  )
}
