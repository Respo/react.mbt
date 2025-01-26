///|
pub extern "js" fn preact_render(vdom : JsValue, parent : @dom.Node) -> Unit =
  #| window.Preact.render(vdom, parent)

///|
pub extern "js" fn preact_h(
  tag : String,
  props : JsValue,
  children : JsValue
) -> JsValue =
  #| window.Preact.h(tag, props, children)

///|
pub type ElementAttrs Map[String, String]

///|
type DOMEvent

///|
type ElementEvents Map[String, (DOMEvent) -> Unit]

///|
type ElementStyle Map[String, String]

///|
struct Element {
  name : String
  attrs : ElementAttrs
  event : ElementEvents
  style : ElementStyle
  children : Array[Element]
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
