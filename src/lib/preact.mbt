///|
pub extern "js" fn preact_render(vdom : JsValue, parent : @dom.Node) -> Unit =
  #| (vdom, parent) => window.Preact.render(vdom, parent)

///|
pub extern "js" fn preact_h(
  tag : String,
  props : JsValue,
  children : JsValue
) -> JsValue =
  #| (tag, props, children) => window.Preact.h(tag, props, children)

///|
pub fn render(el : Element, parent : @dom.Node) -> Unit {
  preact_render(el.to_js_value(), parent)
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
type ElementEvents Map[String, (DOMEvent) -> Unit]

///|
pub fn ElementEvents::new() -> ElementEvents {
  {}
}

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
struct Element {
  name : String
  attrs : ElementAttrs
  event : ElementEvents
  style : ElementStyle
  children : Array[Element]
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
  children : Array[Element]
) -> Element {
  Element::{ name, attrs, event, style, children }
}
