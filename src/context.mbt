///|
/// A typed handle to a React Context object.
struct ReactContext[T] {
  js_value : @dom.JsObscure
  _default_value : T
}

///|
extern "js" fn react_create_context(
  default_value : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (defaultValue) => window.React.createContext(defaultValue)

///|
extern "js" fn react_use_context(context : @dom.JsObscure) -> @dom.JsObscure =
  #| (context) => window.React.useContext(context)

///|
extern "js" fn react_context_provider(
  context : @dom.JsObscure,
  value : @dom.JsObscure,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (context, value, children) => window.React.createElement(context, { value }, ...children)

///|
/// Creates a typed React Context with the value returned when no matching
/// provider exists above a consumer.
///
/// Create contexts outside ordinary render paths, or memoize them when their
/// lifetime intentionally belongs to a component instance.
pub fn[T] create_context(default_value : T) -> ReactContext[T] {
  ReactContext::{
    js_value: react_create_context(@dom.v_to_js_obscure(default_value)),
    _default_value: default_value,
  }
}

///|
/// Reads and subscribes to the nearest provider value for `context`.
/// This is a React Hook and must only be called while rendering a component.
pub fn[T] use_context(context : ReactContext[T]) -> T {
  react_use_context(context.js_value) |> @dom.js_obscure_to_v
}

///|
/// Provides `value` to descendant components without adding a DOM wrapper.
pub fn[T] ReactContext::provider(
  self : ReactContext[T],
  value : T,
  children : Array[VirtualNode],
) -> VirtualNode {
  JsNode(
    react_context_provider(
      self.js_value,
      @dom.v_to_js_obscure(value),
      FixedArray::from_array(children.map(fn(child) { child.to_js_obscure() })),
    ),
  )
}

///|
/// Returns the underlying Context object for explicit JavaScript interoperation.
pub fn[T] ReactContext::to_js_obscure(self : ReactContext[T]) -> @dom.JsObscure {
  self.js_value
}
