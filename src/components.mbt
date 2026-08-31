///|
/// A stable React component type carrying one typed MoonBit props value.
///
/// Render it with `ReactComponent::render`. JavaScript component bridges receive
/// the typed value in a single `moonbitProps` property rather than relying on
/// the generated representation being spread into JavaScript props.
struct ReactComponent[T] {
  js_value : @dom.JsObscure
  _props_marker : T?
}

///|
extern "js" fn react_define_component(
  component_key : @dom.JsObscure,
  render_component : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (componentKey, renderComponent) => {
  #|   const components = globalThis.__moonbitReactComponentTypes ??= new WeakMap();
  #|   let component = components.get(componentKey);
  #|   if (!component) {
  #|     component = (props) => renderComponent(props.moonbitProps);
  #|     components.set(componentKey, component);
  #|   }
  #|   return component;
  #| }

///|
extern "js" fn react_component_element(
  component : @dom.JsObscure,
  props : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (component, moonbitProps) =>
  #|   globalThis.React.createElement(component, { moonbitProps })

///|
extern "js" fn react_memo_component(
  component : @dom.JsObscure,
  are_props_equal : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (component, arePropsEqual) => globalThis.React.memo(
  #|   component,
  #|   arePropsEqual == null
  #|     ? undefined
  #|     : (previous, next) =>
  #|         arePropsEqual(previous.moonbitProps, next.moonbitProps),
  #| )

///|
extern "js" fn react_lazy_component(loader : @dom.JsObscure) -> @dom.JsObscure =
  #| (loader) => globalThis.React.lazy(loader)

///|
extern "js" fn react_component_module(
  component : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (component) => ({ default: component })

///|
extern "js" fn react_suspense(
  fallback : @dom.JsObscure,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (fallback, children) => globalThis.React.createElement(
  #|   globalThis.React.Suspense,
  #|   { fallback },
  #|   ...children,
  #| )

///|
/// React 19.2 Activity visibility modes.
pub(all) enum ActivityMode {
  Visible
  Hidden
} derive(Eq)

///|
/// Returns the React `mode` property for this Activity mode.
pub fn ActivityMode::to_string(self : ActivityMode) -> String {
  match self {
    Visible => "visible"
    Hidden => "hidden"
  }
}

///|
extern "js" fn react_activity(
  mode : String,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (mode, children) => globalThis.React.createElement(
  #|   globalThis.React.Activity,
  #|   { mode },
  #|   ...children,
  #| )

///|
/// Defines a stable typed React component from a MoonBit render function.
/// Prefer module-level declarations; repeated calls with the same function also
/// reuse the same JavaScript component type.
pub fn[T] define_component(
  render_component : (T) -> VirtualNode,
) -> ReactComponent[T] {
  ReactComponent::{
    js_value: react_define_component(
      @dom.v_to_js_obscure(render_component),
      @dom.v_to_js_obscure(fn(props : T) {
        render_component(props).to_js_obscure()
      }),
    ),
    _props_marker: None,
  }
}

///|
/// Declares the expected MoonBit props type for a trusted JavaScript React
/// component. The JavaScript component receives `{ moonbitProps }` and the
/// rendered value remains a `JsNode` escape hatch.
pub fn[T] component_from_js(component : @dom.JsObscure) -> ReactComponent[T] {
  ReactComponent::{ js_value: component, _props_marker: None }
}

///|
/// Renders this component with one typed MoonBit props value.
pub fn[T] ReactComponent::render(
  self : ReactComponent[T],
  props : T,
) -> VirtualNode {
  JsNode(react_component_element(self.js_value, @dom.v_to_js_obscure(props)))
}

///|
/// Returns the underlying React component type for explicit JavaScript
/// interoperation.
pub fn[T] ReactComponent::to_js_obscure(
  self : ReactComponent[T],
) -> @dom.JsObscure {
  self.js_value
}

///|
/// Returns a memoized component. Without `are_props_equal`, React compares the
/// single typed `moonbitProps` value with `Object.is`; a custom comparator
/// receives the previous and next MoonBit values directly.
pub fn[T] ReactComponent::memo(
  self : ReactComponent[T],
  are_props_equal? : (T, T) -> Bool,
) -> ReactComponent[T] {
  let comparator = match are_props_equal {
    Some(callback) => @dom.v_to_js_obscure(callback)
    None => @dom.JsObscure::null()
  }
  ReactComponent::{
    js_value: react_memo_component(self.js_value, comparator),
    _props_marker: None,
  }
}

///|
/// Defines a lazy typed component. Declare it outside render paths. React calls
/// and caches `loader` on first render; the MoonBit async bridge resolves to the
/// `{ default: component }` module shape required by `React.lazy`.
pub fn[T] lazy_component(
  loader : async () -> ReactComponent[T],
) -> ReactComponent[T] {
  let js_loader = fn() {
    @js_async.Promise::from_async(async fn() {
      let component = loader()
      react_component_module(component.js_value)
    })
  }
  ReactComponent::{
    js_value: react_lazy_component(@dom.v_to_js_obscure(js_loader)),
    _props_marker: None,
  }
}

///|
/// Creates a Suspense boundary that displays `fallback` until every child is
/// ready, then reveals the children together.
pub fn suspense(
  fallback : VirtualNode,
  children : Array[VirtualNode],
) -> VirtualNode {
  JsNode(
    react_suspense(
      fallback.to_js_obscure(),
      FixedArray::from_array(children.map(fn(child) { child.to_js_obscure() })),
    ),
  )
}

///|
/// Creates a React 19.2 Activity boundary.
///
/// A hidden Activity keeps its children and their state while hiding their DOM,
/// cleans up their Effects, and deprioritizes their updates. Restoring it to
/// `Visible` remounts those Effects without resetting child state.
pub fn activity(
  mode : ActivityMode,
  children : Array[VirtualNode],
) -> VirtualNode {
  JsNode(
    react_activity(
      mode.to_string(),
      FixedArray::from_array(children.map(fn(child) { child.to_js_obscure() })),
    ),
  )
}
