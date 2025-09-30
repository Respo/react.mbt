///|
fnalias @css.respo_style

///|
typealias @css.RespoStyle

///|
extern "js" fn preact_render(vdom : JsValue, parent : @dom.Node) -> Unit =
  #| (vdom, parent) => {
  #|  return window.Preact.render(vdom, parent)
  #| }

///|
/// Renders a virtual DOM node to the specified parent element.
///
/// This function takes a virtual DOM node and a parent DOM element, then uses
/// the Preact rendering engine to render the virtual node as a real DOM element
/// within the parent.
///
/// # Parameters
/// - `vdom`: The virtual DOM node to render.
/// - `parent`: The parent DOM element where the rendered node will be appended.
///
/// # Example
/// ```moonbit_no_check
/// // Render a virtual element to the document body
/// let custom_elem = create_element(
///   "my-custom-element",
///   ElementAttrs::new(),
///   ElementEvents::new(),
///   style=@css.respo_style(),
///   [Text("Custom content")]
/// )
/// render(custom_elem.to_node(), document.body)
/// ```
pub fn render(vdom : VirtualNode, parent : @dom.Element) -> Unit {
  preact_render(vdom.to_js_value(), parent.reinterpret_as_node())
}

///|
extern "js" fn preact_h(
  tag : String,
  props : JsValue,
  children : JsValue,
) -> JsValue =
  #| (tag, props, children) => window.Preact.h(tag, props, ...children)

///|
extern "js" fn preact_fragment(props : JsValue, children : JsValue) -> JsValue =
  #| (props, children) => window.Preact.h(window.Preact.Fragment, props, ...children)

///|
extern "js" fn preact_use_state(initial : JsValue) -> JsValue =
  #| (initial) => { return window.PreactHooks.useState(initial)}

///|
extern "js" fn state_updater_from_value(v : JsValue) -> (JsValue) -> Unit =
  #| (v) => v

///|
fn[T] any_to_js_value(v : T) -> JsValue = "%identity"

///|
fn[T] any_from_js_value(v : JsValue) -> T = "%identity"

///|
pub fn[T] use_state(initial : T) -> (T, (T) -> Unit) {
  let pair = preact_use_state(any_to_js_value(initial)).to_array()
  let s0 = pair[0]
  let s1 = state_updater_from_value(pair[1])
  (any_from_js_value(s0), fn(value : T) { s1(any_to_js_value(value)) })
}

///|
pub struct ElementAttrs(Map[String, String]) derive(Default)

///|
pub fn ElementAttrs::new() -> ElementAttrs {
  {}
}

///|
pub fn ElementAttrs::add(
  self : ElementAttrs,
  key : String,
  value : String,
) -> ElementAttrs {
  self.inner().set(key, value)
  self
}

///|
pub fn ElementAttrs::set(
  self : ElementAttrs,
  key : String,
  value : String,
) -> Unit {
  self.inner().set(key, value)
}

///|
pub type DOMEvent

///|
pub fn DOMEvent::to_js_any_value(self : DOMEvent) -> JsValue = "%identity"

///|
pub extern "js" fn console_log2(msg : String, v : JsValue) -> Unit =
  #| (msg, v) => { console.log(msg, v) }

///|
priv struct DOMEventHandler((DOMEvent) -> Unit)

///|
struct ElementEvents(Map[String, DOMEventHandler]) derive(Default)

///|
pub fn ElementEvents::new() -> ElementEvents {
  {}
}

///|
extern "js" fn DOMEventHandler::to_js_func(self : DOMEventHandler) -> JsValue =
  #| (f) => { return f }

///|
pub fn ElementEvents::add(
  self : ElementEvents,
  key : String,
  value : (DOMEvent) -> Unit,
) -> ElementEvents {
  self.inner().set(key, value)
  self
}

///|
pub fn ElementEvents::set(
  self : ElementEvents,
  key : String,
  value : (DOMEvent) -> Unit,
) -> Unit {
  self.inner().set(key, value)
}

///|
pub fn ElementEvents::to_js_value(self : ElementEvents) -> JsValue {
  let obj = JsObject::new()
  for key, value in self.inner() {
    obj.set(key, value.to_js_func())
  }
  JsValue::from_object(obj)
}

///|
/// Represents a virtual DOM node in the Preact rendering system.
///
/// This is the core type for building virtual DOM trees. Each variant represents
/// a different kind of node that can be rendered to the actual DOM.
pub(all) enum VirtualNode {
  /// A standard HTML element with attributes, events, and children
  Element(VirtualElement)
  /// A container for multiple child nodes without creating a wrapper element
  Fragment(Array[VirtualNode])
  /// A text node containing plain string content
  Text(String)
  /// A pre-converted JavaScript value for advanced usage (e.g., from `component` function)
  /// already converted to JsValue, hard to convert back
  JsNode(JsValue) // for advanced usage, e.g. connect
}

///|
pub fn VirtualNode::to_js_value(self : VirtualNode) -> JsValue {
  let ret = match self {
    Element(el) => el.to_js_value()
    Fragment(children) => {
      let v = JsArray::new()
      for child in children {
        v.push(child.to_js_value())
      }
      preact_fragment(JsObject::new().to_value(), v.to_value())
    }
    Text(t) => JsValue::from_string(t)
    JsNode(v) => v
  }
  ret
}

///|
/// Represents a virtual DOM element with all its properties and children.
///
/// This structure encapsulates all the information needed to create and manage
/// a DOM element in the virtual DOM tree, including its tag name, attributes,
/// event handlers, styles, and child nodes.
///
pub struct VirtualElement {
  /// The HTML tag name of the element (e.g., "div", "span", "button").
  name : String
  /// HTML attributes for the element (e.g., id, class, data-* attributes).
  attrs : ElementAttrs
  /// Event handlers attached to the element (e.g., click, input, focus).
  event : ElementEvents
  /// CSS styles applied to the element.
  style : RespoStyle
  /// Child virtual nodes contained within this element.
  children : Array[VirtualNode]
}

///|
pub fn VirtualElement::to_node(self : VirtualElement) -> VirtualNode {
  Element(self)
}

///|
fn VirtualElement::to_js_value(self : VirtualElement) -> JsValue {
  let props = JsObject::new()
  for key, value in self.attrs.inner() {
    props.set(key, JsValue::from_string(value))
  }
  let style = JsObject::new()
  for _idx, pair in self.style.0 {
    let (key, value) = pair
    style.set(key, JsValue::from_string(value))
  }
  // TODO events
  props.set("style", JsValue::from_object(style))
  let children = JsArray::new()
  for child in self.children {
    children.push(child.to_js_value())
  }
  for key, value in self.event.inner() {
    let event_name = "on\{first_letter_to_uppercase(key)}"
    props.set(event_name, value.to_js_func())
  }
  preact_h(
    self.name,
    JsValue::from_object(props),
    JsValue::from_array(children),
  )
}

///|
/// Creates a virtual DOM element with the specified properties.
///
/// This is the internal implementation used by built-in element functions like `div`, `span`, etc.
/// It can also be used to create custom HTML elements that are not provided by the library.
///
/// # Parameters
/// - `name`: HTML tag name (e.g., "div", "span", "custom-element")
/// - `attrs`: Element attributes
/// - `event`: Event handlers
/// - `style`: CSS styles
/// - `children`: Child virtual nodes
///
/// # Example
/// ```moonbit
/// // Create a custom element
/// let _custom_elem = create_element(
///   "my-custom-element",
///   ElementAttrs::new(),
///   ElementEvents::new(),
///   style=@css.respo_style(),
///   [Text("Custom content")]
/// )
/// ```
pub fn create_element(
  name : String,
  attrs : ElementAttrs,
  event : ElementEvents,
  style~ : RespoStyle,
  children : Array[VirtualNode],
) -> VirtualElement {
  VirtualElement::{ name, attrs, event, style, children }
}

///|
extern "js" fn create_factory(
  f : (JsValue) -> JsValue,
  props : JsValue,
  children : JsArray,
) -> JsValue =
  #| (f, props, children) => {
  #|   let h0 = window.Preact.h(f, props, ...children);
  #|   return h0;
  #| }

///|
/// Creates a component virtual node from a function, props, and children.
///
/// This bridges MoonBit component functions with Preact's rendering system,
/// enabling type-safe component creation with strongly-typed props.
///
/// # Example
/// ```moonbit_nocheck
/// struct ButtonProps {
///   text : String
///   disabled : Bool
/// } derive(Default)
///
/// fn my_button(props : ButtonProps) -> VirtualNode {
///   button(disabled=props.disabled, [Text(props.text)])
/// }
///
/// let node = component(my_button, ButtonProps { text: "Click me", disabled: false }, [])
/// ```
pub fn[T : JsValueTrait] component(
  /// Component function that transforms props into a virtual node
  f : (T) -> VirtualNode,
  /// Props to pass to the component function
  props : T,
  /// Child nodes to render inside the component
  children : Array[VirtualNode],
) -> VirtualNode {
  let children_js = JsArray::new()
  for child in children {
    children_js.push(child.to_js_value())
  }
  let r = create_factory(
    fn(p) { f(T::from_value(p)).to_js_value() },
    // TODO maybe better to use { value: PROPS} instead of props.to_value()
    // need future refactor to explore it
    props.to_value(),
    children_js,
  )
  JsNode(r)
}

///|
fn first_letter_to_uppercase(s : String) -> String {
  s[0].to_char().unwrap().to_string().to_upper() + (try! s[1:]).to_string()
}
