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
pub extern "js" fn preact_fragment() -> String =
  #| () => window.Preact.Fragment

// pub fn fragment(children : Array[Element]) -> Element {
//   preact_h(preact_fragment(), ElementAttrs::new(), ElementEvents::new(), ElementStyle::new(), children)
// }

///|
pub fn render(el : Element, parent : @dom.Node) -> Unit {
  preact_render(el.to_js_value(), parent)
}

///|
extern "js" fn preact_use_state(
  initial : JsValue
) -> (JsValue, (JsValue) -> Unit) =
  #| (initial) => window.PreactHooks.useState(initial)

///|
pub fn use_state[T : JsValueTrait](initial : T) -> (T, (T) -> Unit) {
  let (state, set_state) = preact_use_state(initial.to_value())
  (T::from_value(state), fn(value) { set_state(value.to_value()) })
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
fn Node::to_js_value(self : Node) -> JsValue {
  match self {
    Element(el) => el.to_js_value()
    Fragment(children) => {
      let v = JsArray::new()
      for child in children {
        v.push(child.to_js_value())
      }
      preact_h(preact_fragment(), JsObject::new().to_value(), v.to_value())
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
  children : Array[Node]
) -> Element {
  Element::{ name, attrs, event, style, children }
}
