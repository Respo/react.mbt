///|
fnalias @css.respo_style

///|
typealias @css.RespoStyle

///|
pub extern "js" fn render(vdom : JsValue, parent : @dom.Node) -> Unit =
  #| (vdom, parent) => {
  #|  return window.Preact.render(vdom, parent)
  #| }

///|
pub extern "js" fn preact_h(
  tag : String,
  props : JsValue,
  children : JsValue,
) -> JsValue =
  #| (tag, props, children) => window.Preact.h(tag, props, ...children)

///|
type PreactFragment

///|
pub extern "js" fn preact_fragment(
  props : JsValue,
  children : JsValue,
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
pub fn[T : StateValue + Show] use_state(initial : T) -> (T, (T) -> Unit) {
  let pair = preact_use_state(initial.to_value()).to_array()
  let s0 = pair[0]
  let s1 = state_updater_from_value(pair[1])
  (T::from_value(s0), fn(value) { s1(value.to_value()) })
}

///|
pub struct ElementAttrs(Map[String, String])

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
struct ElementEvents(Map[String, DOMEventHandler])

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
pub(all) struct ElementStyle(RespoStyle)

///|
pub fn ElementStyle::new() -> ElementStyle {
  ElementStyle(RespoStyle::default())
}

///|
pub(all) enum VirtualNode {
  Element(VirtualElement)
  Fragment(Array[VirtualNode])
  Text(String)
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
pub struct VirtualElement {
  name : String
  attrs : ElementAttrs
  event : ElementEvents
  style : ElementStyle
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
  for _idx, pair in self.style.0.0 {
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
/// a trick for `createElement`
pub fn[T : JsValueTrait] connect(
  f : (T) -> VirtualNode,
  props : T,
  children : Array[VirtualNode],
) -> VirtualNode {
  let children_js = JsArray::new()
  for child in children {
    children_js.push(child.to_js_value())
  }
  let r = create_factory(
    fn(p) { f(T::from_value(p)).to_js_value() },
    props.to_value(),
    children_js,
  )
  JsNode(r)
}

///|
fn first_letter_to_uppercase(s : String) -> String {
  s[0].to_char().unwrap().to_string().to_upper() + (try! s[1:]).to_string()
}
