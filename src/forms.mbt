///|
/// The browser `FormData` payload supplied to React form Actions.
///
/// Convert it with `to_dom_form_data` when the complete file-aware dom-ffi
/// `FormData` API is needed.
#external
pub type ReactFormData

///|
/// Returns the same browser object as dom-ffi `FormData`, without copying its
/// entries. This preserves the React Action callback API while exposing
/// file-aware `FormData` operations.
///
/// [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData)
pub fn ReactFormData::to_dom_form_data(self : ReactFormData) -> @dom.FormData = "%identity"

///|
/// Returns a string form field, or `None` when the field is absent or is a
/// non-string value such as a File.
pub fn ReactFormData::get_string(self : ReactFormData, key : String) -> String? {
  match self.to_dom_form_data().get(key) {
    Some(@dom.FormDataValue::Text(value)) => Some(value)
    _ => None
  }
}

///|
/// A typed React `action` or `formAction` property.
struct FormAction {
  js_value : JsObscure
}

///|
fn FormAction::from_js_value(value : JsObscure) -> FormAction {
  FormAction::{ js_value: value }
}

///|
fn FormAction::to_js_value(self : FormAction) -> JsObscure {
  self.js_value
}

///|
/// Wraps a `use_action_state` dispatcher for a form `action` or submit-control
/// `formAction` property.
pub fn form_action(dispatch : (ReactFormData) -> Unit) -> FormAction {
  FormAction::from_js_value(@dom.v_to_js_obscure(dispatch))
}

///|
/// Converts a MoonBit async form Action into a JavaScript Promise-returning
/// React Action. Rejections are forwarded to React by the official
/// `moonbitlang/async/js_async` bridge.
pub fn async_form_action(action : async (ReactFormData) -> Unit) -> FormAction {
  let js_action = fn(data : ReactFormData) {
    @js_async.Promise::from_async(async fn() { action(data) })
  }
  FormAction::from_js_value(@dom.v_to_js_obscure(js_action))
}

///|
/// Stores state managed by an asynchronous React Action. The MoonBit async
/// reducer is exported as a JavaScript Promise so React can keep `is_pending`
/// true until it settles and can serialize queued Actions.
pub fn[S, A] use_async_action_state(
  initial : S,
  action : async (S, A) -> S,
) -> (S, (A) -> Unit, Bool) {
  let js_action = fn(previous : S, payload : A) {
    @js_async.Promise::from_async(async fn() { action(previous, payload) })
  }
  let pair = react_use_action_state(
    @dom.v_to_js_obscure(js_action),
    any_to_js_value(initial),
  )
  let state : S = any_from_js_value(pair.get("0"))
  let dispatch = fn1_from_js_obscure(pair.get("1"))
  let is_pending : Bool = any_from_js_value(pair.get("2"))
  (state, fn(value : A) { dispatch(any_to_js_value(value)) }, is_pending)
}

///|
extern "js" fn react_use_optimistic(
  value : JsObscure,
  reducer : JsObscure,
) -> JsObscure =
  #| (value, reducer) => globalThis.React.useOptimistic(value, reducer)

///|
/// Returns a temporary optimistic state and a typed dispatcher. React restores
/// the supplied base value when the surrounding Action finishes unless the
/// owner commits a new base value.
pub fn[S, A] use_optimistic(
  value : S,
  reducer : (S, A) -> S,
) -> (S, (A) -> Unit) {
  let pair = react_use_optimistic(
    any_to_js_value(value),
    any_to_js_value(reducer),
  )
  let state : S = any_from_js_value(pair.get("0"))
  let dispatch = fn1_from_js_obscure(pair.get("1"))
  (state, fn(value : A) { dispatch(any_to_js_value(value)) })
}

///|
extern "js" fn react_use_form_status() -> JsObscure =
  #| () => globalThis.ReactDOM.useFormStatus()

///|
/// Status for the nearest parent React form. A component calling this Hook
/// must be rendered below the form rather than in the same component that
/// creates it.
struct FormStatus {
  js_value : JsObscure
}

///|
/// Reads React's submission status for the nearest parent form.
///
/// Call this Hook from a component rendered inside the form. A component that
/// creates the form cannot observe that same form's status with this Hook.
pub fn use_form_status() -> FormStatus {
  FormStatus::{ js_value: react_use_form_status() }
}

///|
extern "js" fn form_status_pending(status : JsObscure) -> Bool =
  #| (status) => status.pending === true

///|
/// Returns whether the nearest parent form Action is currently pending.
pub fn FormStatus::pending(self : FormStatus) -> Bool {
  form_status_pending(self.js_value)
}

///|
extern "js" fn form_status_data(status : JsObscure) -> JsObscure =
  #| (status) => status.data ?? null

///|
/// Returns the submitted data while the parent form Action is pending.
pub fn FormStatus::data(self : FormStatus) -> ReactFormData? {
  let value = form_status_data(self.js_value)
  if value.is_nil() {
    None
  } else {
    Some(@dom.js_obscure_to_v(value))
  }
}

///|
extern "js" fn form_status_method(status : JsObscure) -> String =
  #| (status) => status.method ?? "get"

///|
/// Returns the HTTP method used by the pending parent-form submission.
/// React reports `"get"` when no active submission supplies another method.
pub fn FormStatus::submission_method(self : FormStatus) -> String {
  form_status_method(self.js_value)
}

///|
extern "js" fn form_status_action(status : JsObscure) -> JsObscure =
  #| (status) => status.action ?? null

///|
/// Returns the Action function associated with the pending submission, or
/// `None` when the parent form has no active Action submission.
pub fn FormStatus::action(self : FormStatus) -> FormAction? {
  let value = form_status_action(self.js_value)
  if value.is_nil() {
    None
  } else {
    Some(FormAction::from_js_value(value))
  }
}
