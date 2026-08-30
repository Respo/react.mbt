///|
using @css {respo_style, type RespoStyle}

///|
extern "js" fn react_render(vdom : @dom.JsObscure, parent : @dom.Node) -> Unit =
  #| (vdom, parent) => {
  #|   const roots = globalThis.__moonbitReactRoots ??= new WeakMap();
  #|   let root = roots.get(parent);
  #|   if (!root) {
  #|     root = window.ReactDOMClient.createRoot(parent);
  #|     roots.set(parent, root);
  #|   }
  #|   root.render(vdom);
  #| }

///|
extern "js" fn react_unmount(parent : @dom.Node) -> Unit =
  #| (parent) => {
  #|   const roots = globalThis.__moonbitReactRoots;
  #|   const root = roots?.get(parent);
  #|   if (root) {
  #|     root.unmount();
  #|     roots.delete(parent);
  #|   }
  #| }

///|
/// Renders a virtual DOM node to the specified parent element.
///
/// This function takes a virtual DOM node and a parent DOM element, then uses
/// the React rendering engine to render the virtual node as a real DOM element
/// within the parent. Repeated calls for the same parent reuse its React root.
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
  react_render(vdom.to_js_obscure(), parent.reinterpret_as_node())
}

///|
/// Unmounts the React root associated with a parent element, if one exists.
/// A later call to `render` for the same parent creates a fresh root.
pub fn unmount(parent : @dom.Element) -> Unit {
  react_unmount(parent.reinterpret_as_node())
}

///|
extern "js" fn react_create_element(
  tag : String,
  props : @dom.JsObjectObscure,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (tag, props, children) => window.React.createElement(tag, props, ...children)

///|
extern "js" fn react_fragment(
  props : @dom.JsObjectObscure,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (props, children) => window.React.createElement(window.React.Fragment, props, ...children)

///|
extern "js" fn react_clone_element_with_key(
  node : @dom.JsObscure,
  key : String,
) -> @dom.JsObscure =
  #| (node, key) => window.React.cloneElement(node, { key })

///|
extern "js" fn react_use_state(initial : JsObscure) -> JsObscure =
  #| (initial) => { return window.React.useState(initial)}

///|
// React hook values are emitted by the MoonBit JavaScript runtime. These
// identity bridges intentionally preserve that runtime representation instead
// of serializing values across the JavaScript boundary.
fn state_updater_from_value(v : JsObscure) -> (JsObscure) -> Unit = "%identity"

///|
fn[T] any_to_js_value(v : T) -> JsObscure = "%identity"

///|
fn[T] any_from_js_value(v : JsObscure) -> T = "%identity"

///|
pub fn[T] use_state(initial : T) -> (T, (T) -> Unit) {
  let pair = react_use_state(any_to_js_value(initial))
  let s0 = pair.get("0")
  let s1 = state_updater_from_value(pair.get("1"))
  (any_from_js_value(s0), fn(value : T) { s1(any_to_js_value(value)) })
}

///|
/// Represents a React state update. `Set` replaces state directly and `Update`
/// calculates the next state from React's current value.
pub(all) enum StateUpdate[T] {
  Set(T)
  Update((T) -> T)
}

///|
/// Like `use_state`, but its setter supports functional updates through
/// `StateUpdate::Update`. Prefer this form when the next state depends on the
/// previous value and React may batch or defer updates.
pub fn[T] use_state_with_updater(initial : T) -> (T, (StateUpdate[T]) -> Unit) {
  let pair = react_use_state(any_to_js_value(initial))
  let state : T = any_from_js_value(pair.get("0"))
  let set_state = state_updater_from_value(pair.get("1"))
  (
    state,
    fn(update) {
      match update {
        Set(value) => set_state(any_to_js_value(value))
        Update(update_fn) =>
          set_state(
            @dom.v_to_js_obscure(fn(current) {
              let current : T = any_from_js_value(current)
              any_to_js_value(update_fn(current))
            }),
          )
      }
    },
  )
}

///|
enum ElementPropValue {
  StringProp(String)
  BoolProp(Bool)
  IntProp(Int)
  JsProp(JsObscure)
}

///|
pub struct ElementAttrs(Map[String, ElementPropValue]) derive(Default)

///|
pub fn ElementAttrs::new() -> ElementAttrs {
  ElementAttrs(Map([]))
}

///|
/// Adds a string-valued React property and returns the same attribute map.
pub fn ElementAttrs::add(
  self : ElementAttrs,
  key : String,
  value : String,
) -> ElementAttrs {
  self.0.set(key, StringProp(value))
  self
}

///|
/// Sets a string-valued React property.
pub fn ElementAttrs::set(
  self : ElementAttrs,
  key : String,
  value : String,
) -> Unit {
  self.0.set(key, StringProp(value))
}

///|
/// Sets a boolean React property without converting it to a string.
pub fn ElementAttrs::set_bool(
  self : ElementAttrs,
  key : String,
  value : Bool,
) -> Unit {
  self.0.set(key, BoolProp(value))
}

///|
/// Sets an integer React property without converting it to a string.
pub fn ElementAttrs::set_int(
  self : ElementAttrs,
  key : String,
  value : Int,
) -> Unit {
  self.0.set(key, IntProp(value))
}

///|
/// Sets an explicitly pre-converted JavaScript property. Use this escape hatch
/// for React values such as `ref` that cannot be represented as strings,
/// booleans, or integers.
pub fn ElementAttrs::set_js_value(
  self : ElementAttrs,
  key : String,
  value : JsObscure,
) -> Unit {
  self.0.set(key, JsProp(value))
}

///|
pub type DOMEvent

///|
pub fn DOMEvent::to_js_obscure(self : DOMEvent) -> JsObscure = "%identity"

///|
/// 获取事件目标元素的值（通常用于 input、textarea 等表单元素）
pub extern "js" fn DOMEvent::target_value(self : DOMEvent) -> String =
  #| (event) => event.target ? event.target.value || "" : ""

///|
/// Returns whether the event target is checked. This is intended for controlled
/// checkbox and radio inputs; non-checkable targets return false.
pub extern "js" fn DOMEvent::target_checked(self : DOMEvent) -> Bool =
  #| (event) => event.target?.checked === true

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
pub extern "js" fn console_log2(msg : String, v : JsObscure) -> Unit =
  #| (msg, v) => { console.log(msg, v) }

///|
priv struct DOMEventHandler((DOMEvent) -> Unit)

///|
/// DOM 事件类型枚举
pub(all) enum DOMEventType {
  // 剪贴板事件
  Copy
  Cut
  Paste

  // 输入法组合事件
  CompositionEnd
  CompositionStart
  CompositionUpdate

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

  // 指针事件
  PointerDown
  PointerMove
  PointerUp
  PointerCancel
  PointerEnter
  PointerLeave
  PointerOver
  PointerOut
  GotPointerCapture
  LostPointerCapture

  // 键盘事件
  KeyDown
  KeyUp
  KeyPress
  BeforeInput

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
  Wheel

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

  // CSS 动画和过渡事件
  AnimationStart
  AnimationEnd
  AnimationIteration
  TransitionEnd

  // 其他可冒泡的元素事件
  Invalid
  Toggle
} derive(Eq, Compare, Hash)

///|
/// 将 DOMEventType 转换为字符串
pub fn DOMEventType::to_string(self : DOMEventType) -> String {
  match self {
    Copy => "copy"
    Cut => "cut"
    Paste => "paste"
    CompositionEnd => "compositionend"
    CompositionStart => "compositionstart"
    CompositionUpdate => "compositionupdate"
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
    PointerDown => "pointerdown"
    PointerMove => "pointermove"
    PointerUp => "pointerup"
    PointerCancel => "pointercancel"
    PointerEnter => "pointerenter"
    PointerLeave => "pointerleave"
    PointerOver => "pointerover"
    PointerOut => "pointerout"
    GotPointerCapture => "gotpointercapture"
    LostPointerCapture => "lostpointercapture"
    KeyDown => "keydown"
    KeyUp => "keyup"
    KeyPress => "keypress"
    BeforeInput => "beforeinput"
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
    Wheel => "wheel"
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
    AnimationStart => "animationstart"
    AnimationEnd => "animationend"
    AnimationIteration => "animationiteration"
    TransitionEnd => "transitionend"
    Invalid => "invalid"
    Toggle => "toggle"
  }
}

///|
pub impl Show for DOMEventType with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
struct ElementEvents(Map[DOMEventType, DOMEventHandler]) derive(Default)

///|
pub fn ElementEvents::new() -> ElementEvents {
  ElementEvents(Map([]))
}

///|
fn DOMEventHandler::to_js_func(self : DOMEventHandler) -> JsObscure = "%identity"

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
  self.0.set(event_type, value)
}

///|
pub fn ElementEvents::to_js_value(self : ElementEvents) -> JsObscure {
  // React consumes handler properties such as onClick, not native names like click.
  let obj = @dom.JsObjectObscure::new()
  for event_type, value in self.0 {
    obj.set(dom_event_to_react_handler(event_type), value.to_js_func())
  }
  obj.to_js_obscure()
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
  /// already converted to JsObscure, hard to convert back
  JsNode(@dom.JsObscure) // for advanced usage, e.g. connect
}

///|
pub fn VirtualNode::to_js_obscure(self : VirtualNode) -> @dom.JsObscure {
  let ret = match self {
    Element(el) => el.to_js_value()
    Fragment(children) => {
      let v = []
      for child in children {
        v.push(child.to_js_obscure())
      }
      react_fragment(@dom.JsObjectObscure::new(), FixedArray::from_array(v))
    }
    Text(t) => JsObscure::from_string(t)
    JsNode(v) => v
  }
  ret
}

///|
/// Assigns a stable React reconciliation key to a virtual node.
///
/// This works uniformly for elements, components, fragments, and text without
/// adding a DOM wrapper. Use stable application identities rather than list
/// indexes when rendering dynamic collections.
pub fn VirtualNode::with_key(self : VirtualNode, key : String) -> VirtualNode {
  match self {
    Element(element) => {
      element.attrs.set("key", key)
      Element(element)
    }
    Fragment(children) => {
      let props = @dom.JsObjectObscure::new()
      props.set("key", JsObscure::from_string(key))
      JsNode(
        react_fragment(
          props,
          FixedArray::from_array(
            children.map(fn(child) { child.to_js_obscure() }),
          ),
        ),
      )
    }
    JsNode(node) => JsNode(react_clone_element_with_key(node, key))
    Text(text) => {
      let props = @dom.JsObjectObscure::new()
      props.set("key", JsObscure::from_string(key))
      JsNode(
        react_fragment(
          props,
          FixedArray::from_array([JsObscure::from_string(text)]),
        ),
      )
    }
  }
}

///|
/// Converts legacy DOM attribute names to React-compatible property names.
/// This function provides backward compatibility for traditional HTML attribute names.
/// Most attributes should use the correct React property names directly in element definitions.
///
/// # Parameters
/// - `attr_name`: HTML attribute name such as "class", "for", or "innerHTML".
///
/// # Returns
/// `String` - React-compatible property name.
///
/// ```
/// inspect(dom_attr_to_react_prop("class"), content="className")
/// inspect(dom_attr_to_react_prop("for"), content="htmlFor")
/// inspect(dom_attr_to_react_prop("innerHTML"), content="dangerouslySetInnerHTML")
/// inspect(dom_attr_to_react_prop("id"), content="id")
/// inspect(dom_attr_to_react_prop("data-test"), content="data-test")
/// ```
pub fn dom_attr_to_react_prop(attr_name : String) -> String {
  match attr_name {
    // 保留向后兼容性，支持传统的 HTML 属性名
    "class" => "className"
    "for" => "htmlFor"
    "innerHTML" => "dangerouslySetInnerHTML"
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
  let s0 = name.trim(chars="-")
  // Split into parts by hyphen
  let parts = s0.split("-")
  // Assemble camelCase
  let mut ret = "".to_string()
  let mut idx = 0
  for part in parts {
    if idx == 0 {
      ret = ret + part.to_owned()
    } else if part.length() > 0 {
      ret = ret + first_letter_to_uppercase(part.to_owned())
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
  let style_obj = @dom.JsObjectObscure::new()
  for _idx, pair in style.0 {
    let (key, value) = pair
    style_obj.set(css_prop_to_camel_case(key), JsObscure::from_string(value))
  }
  style_obj
}

///|
fn VirtualElement::to_js_value(self : VirtualElement) -> @dom.JsObscure {
  let props = @dom.JsObjectObscure::new()
  for key, value in self.attrs.0 {
    let react_prop_name = dom_attr_to_react_prop(key)
    let prop_value = match value {
      StringProp(value) => convert_prop_value(react_prop_name, value)
      BoolProp(value) => @dom.v_to_js_obscure(value)
      IntProp(value) => @dom.v_to_js_obscure(value)
      JsProp(value) => value
    }
    props.set(react_prop_name, prop_value)
  }
  let style = convert_style_to_js_object(self.style)
  props.set("style", style.to_js_obscure())
  let children = []
  for child in self.children {
    children.push(child.to_js_obscure())
  }
  for event_type, value in self.event.0 {
    let event_name = dom_event_to_react_handler(event_type)
    props.set(event_name, @dom.v_to_js_obscure(value))
  }
  react_create_element(self.name, props, FixedArray::from_array(children))
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
/// ```moonbit nocheck
/// // Create a custom element
/// let _custom_elem = create_element(
///   "my-custom-element",
///   ElementAttrs::new(),
///   ElementEvents::new(),
///   style=@css.respo_style(),
///   [Text("Custom content")],
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
  f : (@dom.JsObscure) -> @dom.JsObscure,
  props : @dom.JsObscure,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
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
pub fn[T] component(
  /// Component function that transforms props into a virtual node
  f : (T) -> VirtualNode,
  /// Props to pass to the component function
  props : T,
  /// Child nodes to render inside the component
  children : Array[VirtualNode],
) -> VirtualNode {
  let children_js = children.map(fn(child) { child.to_js_obscure() })
  let r = create_factory(
    fn(p) { f(@dom.js_obscure_to_v(p)).to_js_obscure() },
    // Props retain their MoonBit JavaScript representation; React receives no
    // JSON conversion or defensive clone at this boundary.
    @dom.v_to_js_obscure(props),
    FixedArray::from_array(children_js),
  )
  JsNode(r)
}

///|
/// Creates a component virtual node whose function receives the child nodes.
///
/// Use this when a component needs to decide where to place its children. The
/// existing `component` function remains the concise choice for leaf components.
pub fn[T] component_with_children(
  /// Component function that receives props and the original MoonBit child nodes.
  f : (T, Array[VirtualNode]) -> VirtualNode,
  /// Props to pass to the component function.
  props : T,
  /// Child nodes supplied by the component's caller.
  children : Array[VirtualNode],
) -> VirtualNode {
  let children_js = children.map(fn(child) { child.to_js_obscure() })
  let r = create_factory(
    fn(p) { f(@dom.js_obscure_to_v(p), children).to_js_obscure() },
    @dom.v_to_js_obscure(props),
    FixedArray::from_array(children_js),
  )
  JsNode(r)
}

///|
fn first_letter_to_uppercase(s : String) -> String {
  match s.get_char(0) {
    Some(first) => first.to_string().to_upper() + s[1:].to_owned()
    None => ""
  }
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
    Copy => "onCopy"
    Cut => "onCut"
    Paste => "onPaste"
    CompositionEnd => "onCompositionEnd"
    CompositionStart => "onCompositionStart"
    CompositionUpdate => "onCompositionUpdate"
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
    PointerDown => "onPointerDown"
    PointerMove => "onPointerMove"
    PointerUp => "onPointerUp"
    PointerCancel => "onPointerCancel"
    PointerEnter => "onPointerEnter"
    PointerLeave => "onPointerLeave"
    PointerOver => "onPointerOver"
    PointerOut => "onPointerOut"
    GotPointerCapture => "onGotPointerCapture"
    LostPointerCapture => "onLostPointerCapture"
    KeyDown => "onKeyDown"
    KeyUp => "onKeyUp"
    KeyPress => "onKeyPress"
    BeforeInput => "onBeforeInput"
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
    Wheel => "onWheel"
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
    AnimationStart => "onAnimationStart"
    AnimationEnd => "onAnimationEnd"
    AnimationIteration => "onAnimationIteration"
    TransitionEnd => "onTransitionEnd"
    Invalid => "onInvalid"
    Toggle => "onToggle"
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
/// The internal `innerHTML` attribute is converted to React's
/// `dangerouslySetInnerHTML` object; only provide trusted HTML to that API.
///
/// # Parameters
/// - `prop_name`: React property name.
/// - `value`: String value from the attribute.
///
/// # Returns
/// `JsObscure` - Properly typed JavaScript value for React.
///
/// # Inspect Examples
/// inspect(convert_prop_value("checked", "true"), content="JsObscure::from_bool(true)")
/// inspect(convert_prop_value("className", "my-class"), content="JsObscure::from_string(\"my-class\")")
pub fn convert_prop_value(prop_name : String, value : String) -> @dom.JsObscure {
  if prop_name == "dangerouslySetInnerHTML" {
    let html = @dom.JsObjectObscure::new()
    html.set("__html", JsObscure::from_string(value))
    html.to_js_obscure()
  } else if is_boolean_prop(prop_name) {
    match value {
      "true" => JsObscure::from_bool(true)
      "false" => JsObscure::from_bool(false)
      _ => @dom.v_to_js_obscure(value) // fallback for non-standard values
    }
  } else {
    @dom.v_to_js_obscure(value)
  }
}
