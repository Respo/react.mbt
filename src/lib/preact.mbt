///|
pub extern "js" fn render(vdom : JsValue, parent : @dom.Node) -> Unit =
  #| (vdom, parent) => window.Preact.render(vdom, parent)

///|
pub extern "js" fn preact_h(
  tag : String,
  props : JsValue,
  children : JsValue
) -> JsValue =
  #| (tag, props, children) => window.Preact.h(tag, props, ...children)

///|
type PreactFragment

///|
pub extern "js" fn preact_fragment(
  props : JsValue,
  children : JsValue
) -> JsValue =
  #| (props, children) => window.Preact.h(window.Preact.Fragment, props, ...children)

///|
extern "js" fn preact_use_state(initial : JsValue) -> JsValue =
  #| (initial) => { return window.PreactHooks.useState(initial)}

///|
pub trait StateValue {
  to_value(Self) -> JsValue
  from_value(JsValue) -> Self
}

///|
pub impl StateValue for Float with to_value(self) -> JsValue {
  JsValue::from_number(self)
}

///|
pub impl StateValue for Float with from_value(value : JsValue) -> Float {
  value.to_number()
}

///|
pub impl StateValue for Int with to_value(self) -> JsValue {
  JsValue::from_number(self.reinterpret_as_float())
}

///|
pub impl StateValue for Int with from_value(value : JsValue) -> Int {
  value.to_number().reinterpret_as_int()
}

///|
pub impl StateValue for String with to_value(self) -> JsValue {
  JsValue::from_string(self)
}

///|
pub impl StateValue for String with from_value(value : JsValue) -> String {
  value.to_string()
}

///|
extern "js" fn state_updater_from_value(v : JsValue) -> (JsValue) -> Unit =
  #| (v) => v

///|
pub fn use_state[T : StateValue + Show](initial : T) -> (T, (T) -> Unit) {
  let pair = preact_use_state(initial.to_value()).to_array()
  let s0 = pair[0]
  let s1 = state_updater_from_value(pair[1])
  (T::from_value(s0), fn(value) { s1(value.to_value()) })
}

///|
pub type ElementAttrs Map[String, String]

///|
pub fn ElementAttrs::new() -> ElementAttrs {
  {}
}

///|
pub fn ElementAttrs::set(
  self : ElementAttrs,
  key : String,
  value : String
) -> ElementAttrs {
  self._.set(key, value)
  self
}

///|
type DOMEvent

///|
type DOMEventHandler (DOMEvent) -> Unit

///|
type ElementEvents Map[String, DOMEventHandler]

///|
pub fn ElementEvents::new() -> ElementEvents {
  {}
}

///|
extern "js" fn DOMEventHandler::to_js_func(self : DOMEventHandler) -> JsValue =
  #| (f) => { return f }

///|
pub fn ElementEvents::set(
  self : ElementEvents,
  key : String,
  value : (DOMEvent) -> Unit
) -> ElementEvents {
  self._.set(key, value)
  self
}

///|
pub fn ElementEvents::to_js_value(self : ElementEvents) -> JsValue {
  let obj = JsObject::new()
  for key, value in self._ {
    obj.set(key, value.to_js_func())
  }
  JsValue::from_object(obj)
}

///|
type ElementStyle Map[String, String]

///|
pub fn ElementStyle::new() -> ElementStyle {
  {}
}

///|
pub fn ElementStyle::set(
  self : ElementStyle,
  key : String,
  value : String
) -> ElementStyle {
  self._.set(key, value)
  self
}

///|
pub enum Node {
  Element(Element)
  Fragment(Array[Node])
  Text(String)
}

///|
pub fn Node::text(t : String) -> Node {
  Text(t)
}

///|
pub fn Node::fragment(children : Array[Node]) -> Node {
  Fragment(children)
}

///|
pub fn Node::to_js_value(self : Node) -> JsValue {
  match self {
    Element(el) => el.to_js_value()
    Fragment(children) => {
      let v = JsArray::new()
      for child in children {
        v.push(child.to_js_value())
      }
      preact_fragment(JsObject::new().to_value(), v.to_value())
    }
    Text(t) => JsValue::from_string(t)
  }
}

///|
pub struct Element {
  name : String
  attrs : ElementAttrs
  event : ElementEvents
  style : ElementStyle
  children : Array[Node]
}

///|
pub fn Element::to_node(self : Element) -> Node {
  Element(self)
}

///|
fn Element::to_js_value(self : Element) -> JsValue {
  let props = JsObject::new()
  for key, value in self.attrs._ {
    props.set(key, JsValue::from_string(value))
  }
  let style = JsObject::new()
  for key, value in self.style._ {
    style.set(key, JsValue::from_string(value))
  }
  // TODO events
  props.set("style", JsValue::from_object(style))
  let children = JsArray::new()
  for child in self.children {
    children.push(child.to_js_value())
  }
  for key, value in self.event._ {
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
pub fn create_element(
  name : String,
  attrs : ElementAttrs,
  event : ElementEvents,
  style : ElementStyle,
  children : Array[Node]
) -> Element {
  Element::{ name, attrs, event, style, children }
}

///|
pub extern "js" fn create_factory(
  f : (JsValue) -> JsValue,
  props : JsValue,
  children : JsArray
) -> JsValue =
  #| (f, props, children) => { return window.Preact.h(f, props, ...children) }

///|
fn first_letter_to_uppercase(s : String) -> String {
  s[0].to_string().to_upper() + s.substring(start=1)
}
