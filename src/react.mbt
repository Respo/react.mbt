///|
fnalias @css.respo_style

///|
typealias @css.RespoStyle

///|
extern "js" fn react_render(vdom : JsValue, parent : @dom.Node) -> Unit =
  #| (vdom, parent) => {
  #|   const root = window.ReactDOMClient.createRoot(parent);
  #|   root.render(vdom);
  #| }

///|
/// Renders a virtual DOM node to the specified parent element.
///
/// This function takes a virtual DOM node and a parent DOM element, then uses
/// the React rendering engine to render the virtual node as a real DOM element
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
  react_render(vdom.to_js_value(), parent.reinterpret_as_node())
}

///|
extern "js" fn react_create_element(
  tag : String,
  props : @dom.JsObjectObscure,
  children : JsValue,
) -> JsValue =
  #| (tag, props, children) => window.React.createElement(tag, props, ...children)

///|
extern "js" fn react_fragment(
  props : @dom.JsObjectObscure,
  children : JsValue,
) -> JsValue =
  #| (props, children) => window.React.createElement(window.React.Fragment, props, ...children)

///|
extern "js" fn react_use_state(initial : JsValue) -> JsValue =
  #| (initial) => { return window.React.useState(initial)}

///|
extern "js" fn state_updater_from_value(v : JsValue) -> (JsValue) -> Unit =
  #| (v) => v

///|
fn[T] any_to_js_value(v : T) -> JsValue = "%identity"

///|
fn[T] any_from_js_value(v : JsValue) -> T = "%identity"

///|
pub fn[T] use_state(initial : T) -> (T, (T) -> Unit) {
  let pair = react_use_state(any_to_js_value(initial)).to_array()
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
/// 获取事件目标元素的值（通常用于 input、textarea 等表单元素）
pub extern "js" fn DOMEvent::target_value(self : DOMEvent) -> String =
  #| (event) => event.target ? event.target.value || "" : ""

///|
/// 获取键盘事件的键值
pub extern "js" fn DOMEvent::key(self : DOMEvent) -> String =
  #| (event) => event.key || ""

///|
/// 获取键盘事件的键码
pub extern "js" fn DOMEvent::key_code(self : DOMEvent) -> Int =
  #| (event) => event.keyCode || 0

///|
/// 阻止事件的默认行为
pub extern "js" fn DOMEvent::prevent_default(self : DOMEvent) -> Unit =
  #| (event) => event.preventDefault()

///|
/// 阻止事件冒泡
pub extern "js" fn DOMEvent::stop_propagation(self : DOMEvent) -> Unit =
  #| (event) => event.stopPropagation()

///|
/// 获取鼠标事件的 X 坐标
pub extern "js" fn DOMEvent::client_x(self : DOMEvent) -> Int =
  #| (event) => event.clientX || 0

///|
/// 获取鼠标事件的 Y 坐标
pub extern "js" fn DOMEvent::client_y(self : DOMEvent) -> Int =
  #| (event) => event.clientY || 0

///|
/// 检查是否按下了 Ctrl 键
pub extern "js" fn DOMEvent::ctrl_key(self : DOMEvent) -> Bool =
  #| (event) => event.ctrlKey || false

///|
/// 检查是否按下了 Shift 键
pub extern "js" fn DOMEvent::shift_key(self : DOMEvent) -> Bool =
  #| (event) => event.shiftKey || false

///|
/// 检查是否按下了 Alt 键
pub extern "js" fn DOMEvent::alt_key(self : DOMEvent) -> Bool =
  #| (event) => event.altKey || false

///|
/// 检查是否按下了 Meta 键（Mac 上的 Cmd 键）
pub extern "js" fn DOMEvent::meta_key(self : DOMEvent) -> Bool =
  #| (event) => event.metaKey || false

///|
pub extern "js" fn console_log2(msg : String, v : JsValue) -> Unit =
  #| (msg, v) => { console.log(msg, v) }

///|
priv struct DOMEventHandler((DOMEvent) -> Unit)

///|
/// DOM 事件类型枚举
pub(all) enum DOMEventType {
  // 鼠标事件
  Click
  DoubleClick
  MouseDown
  MouseUp
  MouseMove
  MouseEnter
  MouseLeave
  MouseOver
  MouseOut
  ContextMenu

  // 键盘事件
  KeyDown
  KeyUp
  KeyPress

  // 表单事件
  Input
  Change
  Submit
  Reset
  Focus
  Blur
  Select

  // 窗口事件
  Load
  Unload
  Resize
  Scroll

  // 拖拽事件
  Drag
  DragStart
  DragEnd
  DragEnter
  DragLeave
  DragOver
  Drop

  // 触摸事件
  TouchStart
  TouchMove
  TouchEnd
  TouchCancel

  // 其他常用事件
  Error
  Abort
  CanPlay
  CanPlayThrough
  DurationChange
  Ended
  LoadedData
  LoadedMetadata
  LoadStart
  Pause
  Play
  Playing
  Progress
  RateChange
  Seeked
  Seeking
  Stalled
  Suspend
  TimeUpdate
  VolumeChange
  Waiting
} derive(Eq, Compare, Show, Hash)

///|
/// 将 DOMEventType 转换为字符串
pub fn DOMEventType::to_string(self : DOMEventType) -> String {
  match self {
    Click => "click"
    DoubleClick => "dblclick"
    MouseDown => "mousedown"
    MouseUp => "mouseup"
    MouseMove => "mousemove"
    MouseEnter => "mouseenter"
    MouseLeave => "mouseleave"
    MouseOver => "mouseover"
    MouseOut => "mouseout"
    ContextMenu => "contextmenu"
    KeyDown => "keydown"
    KeyUp => "keyup"
    KeyPress => "keypress"
    Input => "input"
    Change => "change"
    Submit => "submit"
    Reset => "reset"
    Focus => "focus"
    Blur => "blur"
    Select => "select"
    Load => "load"
    Unload => "unload"
    Resize => "resize"
    Scroll => "scroll"
    Drag => "drag"
    DragStart => "dragstart"
    DragEnd => "dragend"
    DragEnter => "dragenter"
    DragLeave => "dragleave"
    DragOver => "dragover"
    Drop => "drop"
    TouchStart => "touchstart"
    TouchMove => "touchmove"
    TouchEnd => "touchend"
    TouchCancel => "touchcancel"
    Error => "error"
    Abort => "abort"
    CanPlay => "canplay"
    CanPlayThrough => "canplaythrough"
    DurationChange => "durationchange"
    Ended => "ended"
    LoadedData => "loadeddata"
    LoadedMetadata => "loadedmetadata"
    LoadStart => "loadstart"
    Pause => "pause"
    Play => "play"
    Playing => "playing"
    Progress => "progress"
    RateChange => "ratechange"
    Seeked => "seeked"
    Seeking => "seeking"
    Stalled => "stalled"
    Suspend => "suspend"
    TimeUpdate => "timeupdate"
    VolumeChange => "volumechange"
    Waiting => "waiting"
  }
}

///|
struct ElementEvents(Map[DOMEventType, DOMEventHandler]) derive(Default)

///|
pub fn ElementEvents::new() -> ElementEvents {
  {}
}

///|
extern "js" fn DOMEventHandler::to_js_func(self : DOMEventHandler) -> JsValue =
  #| (f) => { return f }

///|
/// 使用 DOMEventType 添加事件处理器
pub fn ElementEvents::add(
  self : ElementEvents,
  event_type : DOMEventType,
  value : (DOMEvent) -> Unit,
) -> ElementEvents {
  self.set(event_type, value)
  self
}

///|

///|
/// 使用 DOMEventType 设置事件处理器
pub fn ElementEvents::set(
  self : ElementEvents,
  event_type : DOMEventType,
  value : (DOMEvent) -> Unit,
) -> Unit {
  self.inner().set(event_type, value)
}

///|
pub fn ElementEvents::to_js_value(self : ElementEvents) -> JsValue {
  let obj = JsObject::new()
  for event_type, value in self.inner() {
    obj.set(event_type.to_string(), value.to_js_func())
  }
  JsValue::from_object(obj)
}

///|
/// Represents a virtual DOM node in the React rendering system.
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
      react_fragment(@dom.new_js_object(), v.to_value())
    }
    Text(t) => JsValue::from_string(t)
    JsNode(v) => v
  }
  ret
}

///|
/// Converts legacy DOM attribute names to React-compatible property names.
/// This function provides backward compatibility for traditional HTML attribute names.
/// Most attributes should use the correct React property names directly in element definitions.
///
/// # Parameters
/// - `attr_name`: HTML attribute name such as "class", "for", etc.
///
/// # Returns
/// `String` - React-compatible property name.
///
/// ```
/// inspect(dom_attr_to_react_prop("class"), content="className")
/// inspect(dom_attr_to_react_prop("for"), content="htmlFor")
/// inspect(dom_attr_to_react_prop("id"), content="id")
/// inspect(dom_attr_to_react_prop("data-test"), content="data-test")
/// ```
pub fn dom_attr_to_react_prop(attr_name : String) -> String {
  match attr_name {
    // 保留向后兼容性，支持传统的 HTML 属性名
    "class" => "className"
    "for" => "htmlFor"
    // 其他属性名应该在元素定义时就使用正确的 React 属性名
    _ => attr_name
  }
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
/// Converts CSS property names from hyphen-case (kebab-case) to React camelCase.
/// Supports vendor prefixes (leading hyphen) by capitalizing the first segment.
///
/// # Parameters
/// - `name`: CSS property name such as "background-color" or "-webkit-line-clamp".
///
/// # Returns
/// `String` - React-style camelCase property.
///
/// ```
/// inspect(css_prop_to_camel_case("background-color"), content="backgroundColor")
/// inspect(css_prop_to_camel_case("border-top-left-radius"), content="borderTopLeftRadius")
/// inspect(css_prop_to_camel_case("-webkit-line-clamp"), content="WebkitLineClamp")
/// ```
pub fn css_prop_to_camel_case(name : String) -> String {
  // Detect leading hyphen (e.g., -webkit-)
  let had_leading = name.has_prefix("-")
  // Trim leading/trailing hyphens (typically we only expect leading ones)
  let s0 = name.trim("-")
  // Split into parts by hyphen
  let parts = s0.split("-")
  // Assemble camelCase
  let mut ret = "".to_string()
  let mut idx = 0
  for part in parts {
    if idx == 0 {
      ret = ret + part.to_string()
    } else if part.length() > 0 {
      ret = ret + first_letter_to_uppercase(part.to_string())
    }
    idx = idx + 1
  }
  // For vendor prefixes: capitalize first letter (e.g., WebkitLineClamp)
  if had_leading && ret.length() > 0 {
    ret = first_letter_to_uppercase(ret)
  }
  ret
}

///|
/// Converts a RespoStyle to a JavaScript style object.
/// This function takes CSS properties from RespoStyle and converts them to
/// React-compatible camelCase property names with string values.
///
/// # Parameters
/// - `style`: RespoStyle containing CSS properties
///
/// # Returns
/// `JsObject` - JavaScript object with camelCase CSS properties
///
/// # Example
/// ```moonbit_nocheck
/// let style = @css.respo_style(background_color=Red, font_size=16.0 |> Px)
/// let js_style = convert_style_to_js_object(style)
/// // Results in: { backgroundColor: "red", fontSize: "16px" }
/// ```

///|
pub fn convert_style_to_js_object(
  style : @css.RespoStyle,
) -> @dom.JsObjectObscure {
  let style_obj = @dom.new_js_object()
  for _idx, pair in style.0 {
    let (key, value) = pair
    style_obj.set(css_prop_to_camel_case(key), @dom.v_to_js_obscure(value))
  }
  style_obj
}

///|
fn VirtualElement::to_js_value(self : VirtualElement) -> JsValue {
  let props = @dom.new_js_object()
  for key, value in self.attrs.inner() {
    let react_prop_name = dom_attr_to_react_prop(key)
    let prop_value = convert_prop_value(react_prop_name, value)
    props.set(react_prop_name, prop_value)
  }
  let style = convert_style_to_js_object(self.style)
  props.set("style", @dom.v_to_js_obscure(style))
  let children = JsArray::new()
  for child in self.children {
    children.push(child.to_js_value())
  }
  for event_type, value in self.event.inner() {
    let event_name = dom_event_to_react_handler(event_type)
    props.set(event_name, @dom.v_to_js_obscure(value))
  }
  react_create_element(self.name, props, JsValue::from_array(children))
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
  children : Array[JsValue],
) -> JsValue =
  #| (f, props, children) => {
  #|   let h0 = window.React.createElement(f, props, ...children);
  #|   return h0;
  #| }

///|
/// Creates a component virtual node from a function, props, and children.
///
/// This bridges MoonBit component functions with React's rendering system,
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
  let children_js = children.map(fn(child) { child.to_js_value() })
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

///|
/// Converts DOM event types to React-compatible event handler names.
/// Ensures proper camelCase formatting for React event handlers.
///
/// # Parameters
/// - `event_type`: DOM event type enum value.
///
/// # Returns
/// `String` - React-compatible event handler name with "on" prefix.
/// ```
/// inspect(dom_event_to_react_handler(KeyDown), content="onKeyDown")
/// inspect(dom_event_to_react_handler(Click), content="onClick")
/// inspect(dom_event_to_react_handler(MouseEnter), content="onMouseEnter")
/// inspect(dom_event_to_react_handler(DoubleClick), content="onDoubleClick")
/// ```
pub fn dom_event_to_react_handler(event_type : DOMEventType) -> String {
  match event_type {
    Click => "onClick"
    DoubleClick => "onDoubleClick"
    MouseDown => "onMouseDown"
    MouseUp => "onMouseUp"
    MouseMove => "onMouseMove"
    MouseEnter => "onMouseEnter"
    MouseLeave => "onMouseLeave"
    MouseOver => "onMouseOver"
    MouseOut => "onMouseOut"
    ContextMenu => "onContextMenu"
    KeyDown => "onKeyDown"
    KeyUp => "onKeyUp"
    KeyPress => "onKeyPress"
    Input => "onInput"
    Change => "onChange"
    Submit => "onSubmit"
    Reset => "onReset"
    Focus => "onFocus"
    Blur => "onBlur"
    Select => "onSelect"
    Load => "onLoad"
    Unload => "onUnload"
    Resize => "onResize"
    Scroll => "onScroll"
    Drag => "onDrag"
    DragStart => "onDragStart"
    DragEnd => "onDragEnd"
    DragEnter => "onDragEnter"
    DragLeave => "onDragLeave"
    DragOver => "onDragOver"
    Drop => "onDrop"
    TouchStart => "onTouchStart"
    TouchMove => "onTouchMove"
    TouchEnd => "onTouchEnd"
    TouchCancel => "onTouchCancel"
    Error => "onError"
    Abort => "onAbort"
    CanPlay => "onCanPlay"
    CanPlayThrough => "onCanPlayThrough"
    DurationChange => "onDurationChange"
    Ended => "onEnded"
    LoadedData => "onLoadedData"
    LoadedMetadata => "onLoadedMetadata"
    LoadStart => "onLoadStart"
    Pause => "onPause"
    Play => "onPlay"
    Playing => "onPlaying"
    Progress => "onProgress"
    RateChange => "onRateChange"
    Seeked => "onSeeked"
    Seeking => "onSeeking"
    Stalled => "onStalled"
    Suspend => "onSuspend"
    TimeUpdate => "onTimeUpdate"
    VolumeChange => "onVolumeChange"
    Waiting => "onWaiting"
  }
}

///|
/// Checks if a React property should be treated as a boolean attribute.
/// Returns true for attributes that React expects as boolean values.
///
/// # Parameters
/// - `prop_name`: React property name (already converted from DOM attribute).
///
/// # Returns
/// `Bool` - true if the property should be treated as boolean.
///
/// ```
/// inspect(is_boolean_prop("checked"), content="true")
/// inspect(is_boolean_prop("disabled"), content="true")
/// inspect(is_boolean_prop("readOnly"), content="true")
/// inspect(is_boolean_prop("className"), content="false")
/// ```
pub fn is_boolean_prop(prop_name : String) -> Bool {
  match prop_name {
    "checked"
    | "disabled"
    | "readOnly"
    | "required"
    | "autoFocus"
    | "autoPlay"
    | "controls"
    | "defer"
    | "hidden"
    | "loop"
    | "multiple"
    | "muted"
    | "open"
    | "reversed"
    | "selected"
    | "autoComplete"
    | "autoCorrect"
    | "autoCapitalize"
    | "spellCheck"
    | "translate"
    | "contentEditable"
    | "draggable"
    | "suppressContentEditableWarning"
    | "suppressHydrationWarning" => true
    _ => false
  }
}

///|
/// Converts string values to appropriate JavaScript values for React props.
/// Handles boolean attributes by converting "true"/"false" strings to actual booleans.
///
/// # Parameters
/// - `prop_name`: React property name.
/// - `value`: String value from the attribute.
///
/// # Returns
/// `JsValue` - Properly typed JavaScript value for React.
///
/// # Inspect Examples
/// inspect(convert_prop_value("checked", "true"), content="JsValue::from_bool(true)")
/// inspect(convert_prop_value("className", "my-class"), content="JsValue::from_string(\"my-class\")")
pub fn convert_prop_value(prop_name : String, value : String) -> @dom.JsObscure {
  if is_boolean_prop(prop_name) {
    match value {
      "true" => @dom.v_to_js_obscure(true)
      "false" => @dom.v_to_js_obscure(false)
      _ => @dom.v_to_js_obscure(value) // fallback for non-standard values
    }
  } else {
    @dom.v_to_js_obscure(value)
  }
}
