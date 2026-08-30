///|
extern "js" fn install_test_react() -> Unit =
  #| () => {
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createContext: (defaultValue) => ({ defaultValue, currentValue: defaultValue }),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|       cloneElement: (node, props) => ({ ...node, props: { ...node.props, ...props } }),
  #|       useContext: (context) => context.currentValue,
  #|     },
  #|   };
  #| }

///|
extern "js" fn install_component_identity_test_react() -> Unit =
  #| () => {
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) => ({ tag, props, children }),
  #|       cloneElement: (node, props) => ({ ...node, props: { ...node.props, ...props } }),
  #|     },
  #|   };
  #| }

///|
enum NonDefaultReducerState {
  Initial
  Updated
} derive(Eq)

///|
extern "js" fn react_element_child_count(node : @dom.JsObscure) -> Int =
  #| (node) => node.children.length

///|
extern "js" fn react_element_string_prop(
  node : @dom.JsObscure,
  key : String,
) -> String =
  #| (node, key) => node.props[key] || ""

///|
extern "js" fn react_element_string_array_prop(
  node : @dom.JsObscure,
  key : String,
) -> String =
  #| (node, key) => {
  #|   const value = node?.props?.[key];
  #|   return Array.isArray(value) ? value.join("|") : "";
  #| }

///|
extern "js" fn js_value_string_prop(
  value : @dom.JsObscure,
  key : String,
) -> String =
  #| (value, key) => value[key] || ""

///|
extern "js" fn react_element_tag(node : @dom.JsObscure) -> String =
  #| (node) => node.tag

///|
extern "js" fn react_element_tag_equals(
  node : @dom.JsObscure,
  tag : @dom.JsObscure,
) -> Bool =
  #| (node, tag) => node.tag === tag

///|
extern "js" fn react_elements_have_same_tag(
  first : @dom.JsObscure,
  second : @dom.JsObscure,
) -> Bool =
  #| (first, second) => first.tag === second.tag

///|
extern "js" fn render_test_component_factory(
  node : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (node) => node.tag(node.props)

///|
extern "js" fn react_element_first_child_string(
  node : @dom.JsObscure,
) -> String =
  #| (node) => node.children[0]

///|
extern "js" fn react_element_bool_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => node.props[key] === true

///|
extern "js" fn react_element_has_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => Object.hasOwn(node.props, key)

///|
extern "js" fn react_element_prop_equals(
  node : @dom.JsObscure,
  key : String,
  value : @dom.JsObscure,
) -> Bool =
  #| (node, key, value) => node.props[key] === value

///|
extern "js" fn react_element_has_function_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => typeof node.props[key] === "function"

///|
extern "js" fn react_element_int_prop(
  node : @dom.JsObscure,
  key : String,
) -> Int =
  #| (node, key) => node.props[key]

///|
extern "js" fn react_element_inner_html(node : @dom.JsObscure) -> String =
  #| (node) => node.props.dangerouslySetInnerHTML?.__html || ""

///|
extern "js" fn js_value_has_function_prop(
  value : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (value, key) => typeof value[key] === "function"

///|
extern "js" fn js_value_bool(value : @dom.JsObscure) -> Bool =
  #| (value) => value === true

///|
extern "js" fn js_value_string(value : @dom.JsObscure) -> String =
  #| (value) => value

///|
extern "js" fn test_dom_event() -> DOMEvent =
  #| () => ({
  #|   target: { value: "updated value", checked: true },
  #|   key: "Enter",
  #|   keyCode: 13,
  #|   clientX: 24,
  #|   clientY: 48,
  #|   ctrlKey: true,
  #|   shiftKey: true,
  #|   altKey: true,
  #|   metaKey: true,
  #|   preventDefault() { this.defaultPrevented = true; },
  #|   stopPropagation() { this.propagationStopped = true; },
  #| })

///|
extern "js" fn test_dom_event_default_prevented(event : DOMEvent) -> Bool =
  #| (event) => event.defaultPrevented === true

///|
extern "js" fn test_dom_event_propagation_stopped(event : DOMEvent) -> Bool =
  #| (event) => event.propagationStopped === true

///|
extern "js" fn react_element_trigger_event(
  node : @dom.JsObscure,
  handler_name : String,
  event : DOMEvent,
) -> Unit =
  #| (node, handlerName, event) => node.props[handlerName](event)

///|
extern "js" fn install_test_react_dom() -> Unit =
  #| () => {
  #|   let createRootCalls = 0;
  #|   let renderCalls = 0;
  #|   let unmountCalls = 0;
  #|   globalThis.window.ReactDOMClient = {
  #|     createRoot: () => {
  #|       createRootCalls += 1;
  #|       return {
  #|         render: () => { renderCalls += 1; },
  #|         unmount: () => { unmountCalls += 1; },
  #|       };
  #|     },
  #|   };
  #|   globalThis.__moonbitReactRoots = new WeakMap();
  #|   globalThis.__moonbitReactRenderCounts = () =>
  #|     [createRootCalls, renderCalls, unmountCalls];
  #| }

///|
extern "js" fn test_parent_element() -> @dom.Element =
  #| () => ({})

///|
extern "js" fn react_render_create_root_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[0]

///|
extern "js" fn react_render_call_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[1]

///|
extern "js" fn react_unmount_call_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[2]

///|
extern "js" fn install_test_react_hooks() -> Unit =
  #| () => {
  #|   globalThis.__moonbitHookState = {
  #|     state: null,
  #|     reduced: null,
  #|     transitionActions: 0,
  #|   };
  #|   const runTransition = (action) => {
  #|     globalThis.__moonbitHookState.transitionActions += 1;
  #|     action();
  #|   };
  #|   const runEffect = (effect) => {
  #|     const cleanup = effect();
  #|     if (typeof cleanup === "function") cleanup();
  #|   };
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|       useState: (initial) => {
  #|         let current = initial;
  #|         return [initial, (value) => {
  #|           current = typeof value === "function" ? value(current) : value;
  #|           globalThis.__moonbitHookState.state = current;
  #|         }];
  #|       },
  #|       useEffect: runEffect,
  #|       useLayoutEffect: runEffect,
  #|       useMemo: (factory) => factory(),
  #|       useCallback: (callback) => callback,
  #|       useEffectEvent: (callback) => callback,
  #|       useActionState: (action, initial) => [initial, (value) => {
  #|         globalThis.__moonbitHookState.reduced = action(initial, value);
  #|       }, false],
  #|       useRef: (initial) => ({ current: initial }),
  #|       useId: () => "moonbit-test-id",
  #|       useDeferredValue: (value) => value,
  #|       useTransition: () => [false, runTransition],
  #|       startTransition: runTransition,
  #|       useReducer: (reducer, initial) => [initial, (action) => {
  #|         globalThis.__moonbitHookState.reduced = reducer(initial, action);
  #|       }],
  #|     },
  #|   };
  #| }

///|
extern "js" fn hook_test_state() -> Int =
  #| () => globalThis.__moonbitHookState.state

///|
extern "js" fn hook_test_reduced_state() -> Int =
  #| () => globalThis.__moonbitHookState.reduced

///|
extern "js" fn hook_test_transition_action_count() -> Int =
  #| () => globalThis.__moonbitHookState.transitionActions

///|
extern "js" fn set_test_dom_ref(
  js_ref : @dom.JsObscure,
  mounted : Bool,
) -> Unit =
  #| (jsRef, mounted) => {
  #|   jsRef.current = mounted ? { tagName: "INPUT" } : null;
  #| }

///|
extern "js" fn test_callback_throws(callback : () -> Unit) -> Bool =
  #| (callback) => {
  #|   try {
  #|     callback();
  #|     return false;
  #|   } catch (_) {
  #|     return true;
  #|   }
  #| }

///|
extern "js" fn install_test_style_document() -> Unit =
  #| () => {
  #|   const tags = [];
  #|   const head = { appendChild: (tag) => { tags.push(tag); } };
  #|   globalThis.window = {
  #|     document: {
  #|       head,
  #|       createElement: () => {
  #|         const tag = { attributes: {} };
  #|         tag.setAttribute = (key, value) => { tag.attributes[key] = value; };
  #|         return tag;
  #|       },
  #|     },
  #|   };
  #|   globalThis.__moonbitStyleTags = tags;
  #| }

///|
extern "js" fn clear_test_window() -> Unit =
  #| () => { delete globalThis.window; }

///|
extern "js" fn test_style_tag_count() -> Int =
  #| () => globalThis.__moonbitStyleTags.length

///|
extern "js" fn test_style_tag_contains(index : Int, text : String) -> Bool =
  #| (index, text) => globalThis.__moonbitStyleTags[index].innerHTML.includes(text)

///|
fn static_style_for_test() -> String {
  static_style([("&", @css.respo_style(color=@css.CssColor::Blue))])
}

///|
fn static_style_without_document_for_test() -> String {
  static_style([("&", @css.respo_style(color=@css.CssColor::Purple))])
}

///|
fn contained_static_style_for_test() -> String {
  contained_static_style([
    (
      Some("@media (min-width: 640px)"),
      "&:hover",
      @css.respo_style(color=@css.CssColor::Red),
    ),
  ])
}

///|
fn contained_static_style_without_container_for_test() -> String {
  contained_static_style([
    (None, "&:focus", @css.respo_style(color=@css.CssColor::Green)),
  ])
}

///|
fn contained_static_style_without_document_for_test() -> String {
  contained_static_style([
    (None, "&:focus", @css.respo_style(color=@css.CssColor::Purple)),
  ])
}

///|
test "DOM attribute names use React property names" {
  inspect(dom_attr_to_react_prop("class"), content="className")
  inspect(dom_attr_to_react_prop("for"), content="htmlFor")
  inspect(
    dom_attr_to_react_prop("innerHTML"),
    content="dangerouslySetInnerHTML",
  )
  inspect(dom_attr_to_react_prop("data-testid"), content="data-testid")
}

///|
test "CSS property names convert to React camel case" {
  inspect(css_prop_to_camel_case("background-color"), content="backgroundColor")
  inspect(
    css_prop_to_camel_case("-webkit-line-clamp"),
    content="WebkitLineClamp",
  )
  inspect(css_prop_to_camel_case("font"), content="font")
  inspect(css_prop_to_camel_case(""), content="")
}

///|
test "Respo styles convert to React style objects" {
  let style = convert_style_to_js_object(
    @css.respo_style(color=@css.CssColor::Blue, font_size=16),
  ).to_js_obscure()
  inspect(js_value_string_prop(style, "color"), content="blue")
  inspect(js_value_string_prop(style, "fontSize"), content="16px")
}

///|
test "static styles inject once per callsite" {
  install_test_style_document()
  let first = static_style_for_test()
  let second = static_style_for_test()
  assert_eq(first, second)
  inspect(test_style_tag_count(), content="1")
  inspect(test_style_tag_contains(0, "." + first), content="true")
  inspect(test_style_tag_contains(0, "color"), content="true")
  inspect(test_style_tag_contains(0, "blue"), content="true")
}

///|
test "static styles defer injection without a document" {
  clear_test_window()
  let static_class_name = static_style_without_document_for_test()
  let contained_class_name = contained_static_style_without_document_for_test()

  install_test_style_document()
  assert_eq(static_style_without_document_for_test(), static_class_name)
  assert_eq(
    contained_static_style_without_document_for_test(),
    contained_class_name,
  )
  inspect(test_style_tag_count(), content="2")
  inspect(test_style_tag_contains(0, "." + static_class_name), content="true")
  inspect(
    test_style_tag_contains(1, "." + contained_class_name + ":focus"),
    content="true",
  )
}

///|
test "contained static styles preserve their container and selector" {
  install_test_style_document()
  let class_name = contained_static_style_for_test()
  inspect(test_style_tag_count(), content="1")
  inspect(
    test_style_tag_contains(0, "@media (min-width: 640px)"),
    content="true",
  )
  inspect(
    test_style_tag_contains(0, "." + class_name + ":hover"),
    content="true",
  )
  inspect(test_style_tag_contains(0, "red"), content="true")
}

///|
test "contained static styles cache uncontained rules per callsite" {
  install_test_style_document()
  let first = contained_static_style_without_container_for_test()
  let second = contained_static_style_without_container_for_test()
  assert_eq(first, second)
  inspect(test_style_tag_count(), content="1")
  inspect(test_style_tag_contains(0, "." + first + ":focus"), content="true")
  inspect(test_style_tag_contains(0, "green"), content="true")
}

///|
test "DOM events use React handler names" {
  inspect(dom_event_to_react_handler(Click), content="onClick")
  inspect(dom_event_to_react_handler(KeyDown), content="onKeyDown")
  inspect(dom_event_to_react_handler(TouchCancel), content="onTouchCancel")
  inspect(DOMEventType::Click.to_string(), content="click")
}

///|
test "all DOM event types map to native and React names" {
  let cases : Array[(DOMEventType, String, String)] = [
    (DOMEventType::Copy, "copy", "onCopy"),
    (DOMEventType::Cut, "cut", "onCut"),
    (DOMEventType::Paste, "paste", "onPaste"),
    (DOMEventType::CompositionEnd, "compositionend", "onCompositionEnd"),
    (DOMEventType::CompositionStart, "compositionstart", "onCompositionStart"),
    (
      DOMEventType::CompositionUpdate,
      "compositionupdate",
      "onCompositionUpdate",
    ),
    (DOMEventType::Click, "click", "onClick"),
    (DOMEventType::DoubleClick, "dblclick", "onDoubleClick"),
    (DOMEventType::MouseDown, "mousedown", "onMouseDown"),
    (DOMEventType::MouseUp, "mouseup", "onMouseUp"),
    (DOMEventType::MouseMove, "mousemove", "onMouseMove"),
    (DOMEventType::MouseEnter, "mouseenter", "onMouseEnter"),
    (DOMEventType::MouseLeave, "mouseleave", "onMouseLeave"),
    (DOMEventType::MouseOver, "mouseover", "onMouseOver"),
    (DOMEventType::MouseOut, "mouseout", "onMouseOut"),
    (DOMEventType::ContextMenu, "contextmenu", "onContextMenu"),
    (DOMEventType::PointerDown, "pointerdown", "onPointerDown"),
    (DOMEventType::PointerMove, "pointermove", "onPointerMove"),
    (DOMEventType::PointerUp, "pointerup", "onPointerUp"),
    (DOMEventType::PointerCancel, "pointercancel", "onPointerCancel"),
    (DOMEventType::PointerEnter, "pointerenter", "onPointerEnter"),
    (DOMEventType::PointerLeave, "pointerleave", "onPointerLeave"),
    (DOMEventType::PointerOver, "pointerover", "onPointerOver"),
    (DOMEventType::PointerOut, "pointerout", "onPointerOut"),
    (
      DOMEventType::GotPointerCapture,
      "gotpointercapture",
      "onGotPointerCapture",
    ),
    (
      DOMEventType::LostPointerCapture,
      "lostpointercapture",
      "onLostPointerCapture",
    ),
    (DOMEventType::KeyDown, "keydown", "onKeyDown"),
    (DOMEventType::KeyUp, "keyup", "onKeyUp"),
    (DOMEventType::KeyPress, "keypress", "onKeyPress"),
    (DOMEventType::BeforeInput, "beforeinput", "onBeforeInput"),
    (DOMEventType::Input, "input", "onInput"),
    (DOMEventType::Change, "change", "onChange"),
    (DOMEventType::Submit, "submit", "onSubmit"),
    (DOMEventType::Reset, "reset", "onReset"),
    (DOMEventType::Focus, "focus", "onFocus"),
    (DOMEventType::Blur, "blur", "onBlur"),
    (DOMEventType::Select, "select", "onSelect"),
    (DOMEventType::Load, "load", "onLoad"),
    (DOMEventType::Unload, "unload", "onUnload"),
    (DOMEventType::Resize, "resize", "onResize"),
    (DOMEventType::Scroll, "scroll", "onScroll"),
    (DOMEventType::Wheel, "wheel", "onWheel"),
    (DOMEventType::Drag, "drag", "onDrag"),
    (DOMEventType::DragStart, "dragstart", "onDragStart"),
    (DOMEventType::DragEnd, "dragend", "onDragEnd"),
    (DOMEventType::DragEnter, "dragenter", "onDragEnter"),
    (DOMEventType::DragLeave, "dragleave", "onDragLeave"),
    (DOMEventType::DragOver, "dragover", "onDragOver"),
    (DOMEventType::Drop, "drop", "onDrop"),
    (DOMEventType::TouchStart, "touchstart", "onTouchStart"),
    (DOMEventType::TouchMove, "touchmove", "onTouchMove"),
    (DOMEventType::TouchEnd, "touchend", "onTouchEnd"),
    (DOMEventType::TouchCancel, "touchcancel", "onTouchCancel"),
    (DOMEventType::Error, "error", "onError"),
    (DOMEventType::Abort, "abort", "onAbort"),
    (DOMEventType::CanPlay, "canplay", "onCanPlay"),
    (DOMEventType::CanPlayThrough, "canplaythrough", "onCanPlayThrough"),
    (DOMEventType::DurationChange, "durationchange", "onDurationChange"),
    (DOMEventType::Ended, "ended", "onEnded"),
    (DOMEventType::LoadedData, "loadeddata", "onLoadedData"),
    (DOMEventType::LoadedMetadata, "loadedmetadata", "onLoadedMetadata"),
    (DOMEventType::LoadStart, "loadstart", "onLoadStart"),
    (DOMEventType::Pause, "pause", "onPause"),
    (DOMEventType::Play, "play", "onPlay"),
    (DOMEventType::Playing, "playing", "onPlaying"),
    (DOMEventType::Progress, "progress", "onProgress"),
    (DOMEventType::RateChange, "ratechange", "onRateChange"),
    (DOMEventType::Seeked, "seeked", "onSeeked"),
    (DOMEventType::Seeking, "seeking", "onSeeking"),
    (DOMEventType::Stalled, "stalled", "onStalled"),
    (DOMEventType::Suspend, "suspend", "onSuspend"),
    (DOMEventType::TimeUpdate, "timeupdate", "onTimeUpdate"),
    (DOMEventType::VolumeChange, "volumechange", "onVolumeChange"),
    (DOMEventType::Waiting, "waiting", "onWaiting"),
    (DOMEventType::AnimationStart, "animationstart", "onAnimationStart"),
    (DOMEventType::AnimationEnd, "animationend", "onAnimationEnd"),
    (
      DOMEventType::AnimationIteration,
      "animationiteration",
      "onAnimationIteration",
    ),
    (DOMEventType::TransitionEnd, "transitionend", "onTransitionEnd"),
    (DOMEventType::Invalid, "invalid", "onInvalid"),
    (DOMEventType::Toggle, "toggle", "onToggle"),
  ]
  for case in cases {
    let (event_type, native_name, react_name) = case
    assert_eq(event_type.to_string(), native_name)
    assert_eq(dom_event_to_react_handler(event_type), react_name)
  }
  inspect(DOMEventType::Click, content="click")
}

///|
test "ElementEvents serializes React handler property names" {
  let events = ElementEvents::new().add(Click, fn(_event) {  })
  inspect(
    js_value_has_function_prop(events.to_js_value(), "onClick"),
    content="true",
  )
}

///|
test "all built-in element helpers emit their HTML tag" {
  install_test_react()
  let cases : Array[(VirtualNode, String)] = [
    (span([]), "span"),
    (p([]), "p"),
    (label([]), "label"),
    (h1([]), "h1"),
    (h2([]), "h2"),
    (h3([]), "h3"),
    (h4([]), "h4"),
    (h5([]), "h5"),
    (h6([]), "h6"),
    (a([]), "a"),
    (div([]), "div"),
    (input(), "input"),
    (button([]), "button"),
    (textarea(), "textarea"),
    (select([]), "select"),
    (option([]), "option"),
    (section([]), "section"),
    (article([]), "article"),
    (header([]), "header"),
    (footer([]), "footer"),
    (nav([]), "nav"),
    (aside([]), "aside"),
    (ul([]), "ul"),
    (ol([]), "ol"),
    (li([]), "li"),
    (img(), "img"),
    (video([]), "video"),
    (audio([]), "audio"),
  ]
  for case in cases {
    let (node, tag) = case
    assert_eq(react_element_tag(node.to_js_obscure()), tag)
  }
}

///|
test "text, structure, and list helpers preserve common optional props" {
  install_test_react()
  let nodes : Array[VirtualNode] = [
    p(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h1(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h2(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h3(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h4(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h5(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h6(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    a(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    div(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    section(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    article(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    header(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    footer(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    nav(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    aside(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    ul(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    ol(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    li(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
  ]
  for node in nodes {
    let value = node.to_js_obscure()
    assert_eq(react_element_string_prop(value, "id"), "common-id")
    assert_eq(react_element_string_prop(value, "className"), "base extra-class")
    assert_eq(react_element_inner_html(value), "<em>trusted</em>")
    assert_eq(react_element_has_function_prop(value, "onClick"), true)
  }

  let label_node = label(
    id="common-id",
    class_name="base",
    class_list=["extra-class"],
    innerHTML="<em>trusted</em>",
    on_click=fn(_event) {  },
    for_="input-id",
    [],
  ).to_js_obscure()
  assert_eq(react_element_string_prop(label_node, "id"), "common-id")
  assert_eq(
    react_element_string_prop(label_node, "className"),
    "base extra-class",
  )
  assert_eq(react_element_inner_html(label_node), "<em>trusted</em>")
  assert_eq(react_element_has_function_prop(label_node, "onClick"), true)
  inspect(react_element_string_prop(label_node, "htmlFor"), content="input-id")
}

///|
test "input types use valid HTML values" {
  inspect(InputType::Button.to_string(), content="button")
  inspect(InputType::Checkbox.to_string(), content="checkbox")
  inspect(InputType::Color.to_string(), content="color")
  inspect(InputType::Date.to_string(), content="date")
  inspect(InputType::DatetimeLocal.to_string(), content="datetime-local")
  inspect(InputType::Email.to_string(), content="email")
  inspect(InputType::File.to_string(), content="file")
  inspect(InputType::Hidden.to_string(), content="hidden")
  inspect(InputType::Image.to_string(), content="image")
  inspect(InputType::Month.to_string(), content="month")
  inspect(InputType::Number.to_string(), content="number")
  inspect(InputType::Password.to_string(), content="password")
  inspect(InputType::Radio.to_string(), content="radio")
  inspect(InputType::Range.to_string(), content="range")
  inspect(InputType::Reset.to_string(), content="reset")
  inspect(InputType::Search.to_string(), content="search")
  inspect(InputType::Submit.to_string(), content="submit")
  inspect(InputType::Tel.to_string(), content="tel")
  inspect(InputType::Text.to_string(), content="text")
  inspect(InputType::Time.to_string(), content="time")
  inspect(InputType::Url.to_string(), content="url")
  inspect(InputType::Week.to_string(), content="week")
}

///|
test "boolean React properties are recognized" {
  inspect(is_boolean_prop("checked"), content="true")
  inspect(is_boolean_prop("readOnly"), content="true")
  inspect(is_boolean_prop("className"), content="false")
}

///|
test "legacy boolean string props retain their React value type" {
  inspect(js_value_bool(convert_prop_value("checked", "true")), content="true")
  inspect(
    js_value_bool(convert_prop_value("checked", "false")),
    content="false",
  )
  inspect(
    js_value_string(convert_prop_value("checked", "mixed")),
    content="mixed",
  )
}

///|
test "virtual elements convert each child exactly once" {
  install_test_react()
  let node = create_element(
    "div",
    ElementAttrs::new(),
    ElementEvents::new(),
    style=@css.respo_style(),
    [Text("first"), Text("second")],
  ).to_node()
  inspect(react_element_child_count(node.to_js_obscure()), content="2")
}

///|
test "fragments create React fragment nodes with every child" {
  install_test_react()
  let fragment = VirtualNode::Fragment([
    VirtualNode::Text("first"),
    VirtualNode::Text("second"),
  ]).to_js_obscure()
  inspect(react_element_child_count(fragment), content="2")
}

///|
test "virtual nodes accept stable reconciliation keys" {
  install_test_react()
  let node = div([Text("keyed child")]).with_key("todo-42").to_js_obscure()
  inspect(react_element_string_prop(node, "key"), content="todo-42")
  inspect(react_element_child_count(node), content="1")
  inspect(react_element_tag(node), content="div")
}

///|
test "contexts preserve typed defaults and provider values" {
  install_test_react()
  let context = create_context("fallback")
  inspect(use_context(context), content="fallback")
  let provider = context.provider("provided", [Text("child")]).to_js_obscure()
  inspect(
    react_element_tag_equals(provider, context.to_js_obscure()),
    content="true",
  )
  inspect(react_element_string_prop(provider, "value"), content="provided")
  inspect(react_element_child_count(provider), content="1")
}

///|
test "attributes set through ElementAttrs are converted to React props" {
  install_test_react()
  let attrs = ElementAttrs::new().add("title", "first")
  attrs.set("title", "updated")
  attrs.set_bool("checked", false)
  attrs.set_int("tabIndex", 3)
  let node = create_element(
    "div",
    attrs,
    ElementEvents::new(),
    style=@css.respo_style(),
    [],
  ).to_node()
  inspect(
    react_element_string_prop(node.to_js_obscure(), "title"),
    content="updated",
  )
  inspect(
    react_element_has_prop(node.to_js_obscure(), "checked"),
    content="true",
  )
  inspect(
    react_element_bool_prop(node.to_js_obscure(), "checked"),
    content="false",
  )
  inspect(react_element_int_prop(node.to_js_obscure(), "tabIndex"), content="3")
}

///|
test "form handlers receive DOM event values through React props" {
  install_test_react()
  let mut received_value = ""
  let node = input(on_change=fn(event) { received_value = event.target_value() }).to_js_obscure()
  react_element_trigger_event(node, "onChange", test_dom_event())
  inspect(received_value, content="updated value")
}

///|
test "DOMEvent exposes keyboard, pointer, modifier, and control APIs" {
  let event = test_dom_event()
  inspect(event.target_value(), content="updated value")
  inspect(event.target_checked(), content="true")
  inspect(event.key(), content="Enter")
  inspect(event.key_code(), content="13")
  inspect(event.client_x(), content="24")
  inspect(event.client_y(), content="48")
  inspect(event.ctrl_key(), content="true")
  inspect(event.shift_key(), content="true")
  inspect(event.alt_key(), content="true")
  inspect(event.meta_key(), content="true")
  event.prevent_default()
  event.stop_propagation()
  inspect(test_dom_event_default_prevented(event), content="true")
  inspect(test_dom_event_propagation_stopped(event), content="true")
}

///|
test "innerHTML uses React's required object prop" {
  install_test_react()
  let node = div(innerHTML="<strong>trusted</strong>", []).to_js_obscure()
  inspect(react_element_inner_html(node), content="<strong>trusted</strong>")
}

///|
test "invalid innerHTML and form prop combinations are rejected" {
  install_test_react()
  inspect(
    test_callback_throws(fn() {
      let _ = div(innerHTML="<strong>trusted</strong>", [
        Text("conflicting child"),
      ]).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(value="controlled", default_value="initial").to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(checked=true, default_checked=false).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = textarea(value="controlled", default_value="initial").to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = select(value="controlled", default_value="initial", []).to_js_obscure()
    }),
    content="true",
  )
  let selected_attrs = ElementAttrs::new()
  selected_attrs.set_bool("selected", true)
  inspect(
    test_callback_throws(fn() {
      let _ = option(attrs=selected_attrs, [Text("unsupported")]).to_js_obscure()
    }),
    content="true",
  )
}

///|
test "uncontrolled form defaults preserve strings and false booleans" {
  install_test_react()
  let input_node = input(default_value="initial", default_checked=false).to_js_obscure()
  inspect(
    react_element_string_prop(input_node, "defaultValue"),
    content="initial",
  )
  inspect(react_element_has_prop(input_node, "defaultChecked"), content="true")
  inspect(
    react_element_bool_prop(input_node, "defaultChecked"),
    content="false",
  )
  let textarea_node = textarea(default_value="draft").to_js_obscure()
  inspect(
    react_element_string_prop(textarea_node, "defaultValue"),
    content="draft",
  )
  let select_node = select(default_value="second", []).to_js_obscure()
  inspect(
    react_element_string_prop(select_node, "defaultValue"),
    content="second",
  )
}

///|
test "controlled forms require change handling or explicit read-only state" {
  install_test_react()
  inspect(
    test_callback_throws(fn() { let _ = input(value="locked").to_js_obscure() }),
    content="true",
  )
  let readonly_input = input(value="locked", read_only=true).to_js_obscure()
  inspect(react_element_bool_prop(readonly_input, "readOnly"), content="true")
  let controlled_textarea = textarea(value="editable", on_change=fn(_) {  }).to_js_obscure()
  inspect(
    react_element_has_function_prop(controlled_textarea, "onChange"),
    content="true",
  )
  let checkbox_value = input(type_=Checkbox, value="submitted-value").to_js_obscure()
  inspect(
    react_element_string_prop(checkbox_value, "value"),
    content="submitted-value",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(type_=File, value="forbidden").to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = select(value="first", [option(value="first", [Text("First")])]).to_js_obscure()
    }),
    content="true",
  )
}

///|
test "multiple selects require array values" {
  install_test_react()
  inspect(
    test_callback_throws(fn() {
      let _ = select(value="first", multiple=true, []).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = select(values=["first"], []).to_js_obscure()
    }),
    content="true",
  )
  let manual_multiple_value = ElementAttrs::new()
  manual_multiple_value.set_bool("multiple", true)
  manual_multiple_value.set("value", "first")
  inspect(
    test_callback_throws(fn() {
      let _ = create_element(
          "select",
          manual_multiple_value,
          ElementEvents::new(),
          style=@css.respo_style(),
          [],
        )
        .to_node()
        .to_js_obscure()
    }),
    content="true",
  )
  let manual_multiple_default = ElementAttrs::new()
  manual_multiple_default.set_bool("multiple", true)
  manual_multiple_default.set("defaultValue", "first")
  inspect(
    test_callback_throws(fn() {
      let _ = create_element(
          "select",
          manual_multiple_default,
          ElementEvents::new(),
          style=@css.respo_style(),
          [],
        )
        .to_node()
        .to_js_obscure()
    }),
    content="true",
  )
  let manual_single_value = ElementAttrs::new()
  manual_single_value.set_js_value(
    "value",
    @dom.JsObscure::from_array([@dom.JsObscure::from_string("first")]),
  )
  inspect(
    test_callback_throws(fn() {
      let _ = create_element(
          "select",
          manual_single_value,
          ElementEvents::new(),
          style=@css.respo_style(),
          [],
        )
        .to_node()
        .to_js_obscure()
    }),
    content="true",
  )
  let controlled = select(
    values=["first", "second"],
    multiple=true,
    on_change=fn(_) {  },
    [],
  ).to_js_obscure()
  inspect(
    react_element_string_array_prop(controlled, "value"),
    content="first|second",
  )
  let uncontrolled = select(default_values=["second"], multiple=true, []).to_js_obscure()
  inspect(
    react_element_string_array_prop(uncontrolled, "defaultValue"),
    content="second",
  )
  inspect(react_element_string_array_prop(uncontrolled, "value"), content="")
}

///|
test "element helpers preserve form, link, and media props" {
  install_test_react()

  let label_node = label(for_="email", []).to_js_obscure()
  inspect(react_element_tag(label_node), content="label")
  inspect(react_element_string_prop(label_node, "htmlFor"), content="email")

  let input_node = input(
    id="terms",
    class_name="field",
    class_list=["controlled"],
    type_=Checkbox,
    value="accepted",
    placeholder="accept terms",
    disabled=true,
    checked=false,
    on_click=fn(_event) {  },
    on_input=fn(_event) {  },
  ).to_js_obscure()
  inspect(react_element_tag(input_node), content="input")
  inspect(react_element_string_prop(input_node, "id"), content="terms")
  inspect(
    react_element_string_prop(input_node, "className"),
    content="field controlled",
  )
  inspect(react_element_string_prop(input_node, "type"), content="checkbox")
  inspect(react_element_bool_prop(input_node, "disabled"), content="true")
  inspect(react_element_has_prop(input_node, "checked"), content="true")
  inspect(react_element_bool_prop(input_node, "checked"), content="false")
  inspect(
    react_element_has_function_prop(input_node, "onClick"),
    content="true",
  )
  inspect(
    react_element_has_function_prop(input_node, "onInput"),
    content="true",
  )

  let button_node = button(
    id="submit",
    class_name="action",
    class_list=["primary"],
    innerHTML="<b>Submit</b>",
    button_type="submit",
    disabled=true,
    on_click=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(button_node, "id"), content="submit")
  inspect(
    react_element_string_prop(button_node, "className"),
    content="action primary",
  )
  inspect(react_element_inner_html(button_node), content="<b>Submit</b>")
  inspect(react_element_string_prop(button_node, "type"), content="submit")
  inspect(react_element_bool_prop(button_node, "disabled"), content="true")
  inspect(
    react_element_has_function_prop(button_node, "onClick"),
    content="true",
  )

  let link_node = a(href="/docs", target="_blank", [Text("docs")]).to_js_obscure()
  inspect(react_element_tag(link_node), content="a")
  inspect(react_element_string_prop(link_node, "href"), content="/docs")
  inspect(react_element_string_prop(link_node, "target"), content="_blank")

  let media_node = video(
    id="video",
    class_name="media",
    class_list=["wide"],
    src="movie.mp4",
    controls=true,
    autoplay=true,
    loop_enabled=true,
    muted=true,
    width="640",
    height="360",
    on_click=fn(_event) {  },
    on_play=fn(_event) {  },
    on_pause=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_tag(media_node), content="video")
  inspect(react_element_string_prop(media_node, "id"), content="video")
  inspect(
    react_element_string_prop(media_node, "className"),
    content="media wide",
  )
  inspect(react_element_bool_prop(media_node, "controls"), content="true")
  inspect(react_element_bool_prop(media_node, "autoPlay"), content="true")
  inspect(react_element_bool_prop(media_node, "loop"), content="true")
  inspect(react_element_bool_prop(media_node, "muted"), content="true")
  inspect(react_element_string_prop(media_node, "width"), content="640")
  inspect(react_element_string_prop(media_node, "height"), content="360")
  inspect(
    react_element_has_function_prop(media_node, "onClick"),
    content="true",
  )
  inspect(react_element_has_function_prop(media_node, "onPlay"), content="true")
  inspect(
    react_element_has_function_prop(media_node, "onPause"),
    content="true",
  )

  let audio_node = audio(
    id="audio",
    class_name="media",
    class_list=["sound"],
    src="sound.mp3",
    controls=true,
    autoplay=true,
    loop_enabled=true,
    muted=true,
    on_play=fn(_event) {  },
    on_pause=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_tag(audio_node), content="audio")
  inspect(react_element_string_prop(audio_node, "id"), content="audio")
  inspect(
    react_element_string_prop(audio_node, "className"),
    content="media sound",
  )
  inspect(react_element_bool_prop(audio_node, "controls"), content="true")
  inspect(react_element_bool_prop(audio_node, "autoPlay"), content="true")
  inspect(react_element_bool_prop(audio_node, "loop"), content="true")
  inspect(react_element_bool_prop(audio_node, "muted"), content="true")
  inspect(react_element_has_function_prop(audio_node, "onPlay"), content="true")
  inspect(
    react_element_has_function_prop(audio_node, "onPause"),
    content="true",
  )

  let select_node = select(
    id="choices",
    class_name="field",
    class_list=["multiple"],
    values=["second"],
    disabled=true,
    multiple=true,
    on_change=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(select_node, "id"), content="choices")
  inspect(
    react_element_string_prop(select_node, "className"),
    content="field multiple",
  )
  inspect(
    react_element_string_array_prop(select_node, "value"),
    content="second",
  )
  inspect(react_element_bool_prop(select_node, "disabled"), content="true")
  inspect(react_element_bool_prop(select_node, "multiple"), content="true")
  inspect(
    react_element_has_function_prop(select_node, "onChange"),
    content="true",
  )

  let option_node = option(
    id="second",
    class_name="choice",
    class_list=["selected"],
    innerHTML="<i>Second</i>",
    value="second",
    disabled=true,
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(option_node, "id"), content="second")
  inspect(
    react_element_string_prop(option_node, "className"),
    content="choice selected",
  )
  inspect(react_element_inner_html(option_node), content="<i>Second</i>")
  inspect(react_element_string_prop(option_node, "value"), content="second")
  inspect(react_element_bool_prop(option_node, "disabled"), content="true")

  let textarea_node = textarea(
    id="notes",
    class_name="field",
    class_list=["large"],
    value="hello",
    placeholder="notes",
    rows=3,
    cols=20,
    disabled=true,
    on_change=fn(_event) {  },
    on_input=fn(_event) {  },
  ).to_js_obscure()
  inspect(react_element_string_prop(textarea_node, "id"), content="notes")
  inspect(
    react_element_string_prop(textarea_node, "className"),
    content="field large",
  )
  inspect(react_element_string_prop(textarea_node, "value"), content="hello")
  inspect(
    react_element_string_prop(textarea_node, "placeholder"),
    content="notes",
  )
  inspect(react_element_int_prop(textarea_node, "rows"), content="3")
  inspect(react_element_int_prop(textarea_node, "cols"), content="20")
  inspect(react_element_bool_prop(textarea_node, "disabled"), content="true")
  inspect(
    react_element_has_function_prop(textarea_node, "onChange"),
    content="true",
  )
  inspect(
    react_element_has_function_prop(textarea_node, "onInput"),
    content="true",
  )

  let image_node = img(
    id="logo",
    class_name="image",
    class_list=["responsive"],
    src="logo.svg",
    alt="Logo",
    width="120",
    height="40",
    on_click=fn(_event) {  },
    on_load=fn(_event) {  },
    on_error=fn(_event) {  },
  ).to_js_obscure()
  inspect(react_element_string_prop(image_node, "id"), content="logo")
  inspect(
    react_element_string_prop(image_node, "className"),
    content="image responsive",
  )
  inspect(react_element_string_prop(image_node, "src"), content="logo.svg")
  inspect(react_element_string_prop(image_node, "alt"), content="Logo")
  inspect(react_element_string_prop(image_node, "width"), content="120")
  inspect(react_element_string_prop(image_node, "height"), content="40")
  inspect(
    react_element_has_function_prop(image_node, "onClick"),
    content="true",
  )
  inspect(react_element_has_function_prop(image_node, "onLoad"), content="true")
  inspect(
    react_element_has_function_prop(image_node, "onError"),
    content="true",
  )
}

///|
test "text element helpers combine classes and handlers" {
  install_test_react()
  let node = span(
    id="notice",
    class_name="base",
    class_list=["expanded", "active"],
    innerHTML="<em>trusted</em>",
    on_click=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(node, "id"), content="notice")
  inspect(
    react_element_string_prop(node, "className"),
    content="base expanded active",
  )
  inspect(react_element_inner_html(node), content="<em>trusted</em>")
  inspect(react_element_has_function_prop(node, "onClick"), content="true")
}

///|
test "render reuses the React root for a parent element" {
  install_test_react_dom()
  let parent = test_parent_element()
  render(Text("first"), parent)
  render(Text("second"), parent)
  inspect(react_render_create_root_count(), content="1")
  inspect(react_render_call_count(), content="2")
}

///|
test "unmount releases the React root for a parent element" {
  install_test_react_dom()
  let parent = test_parent_element()
  render(Text("first"), parent)
  unmount(parent)
  render(Text("second"), parent)
  inspect(react_render_create_root_count(), content="2")
  inspect(react_unmount_call_count(), content="1")
}

///|
test "hook wrappers preserve MoonBit values and callbacks" {
  install_test_react_hooks()
  let (value, set_value) = use_state(1)
  inspect(value, content="1")
  set_value(2)
  inspect(hook_test_state(), content="2")

  let (updatable, update_value) = use_state_with_updater(3)
  inspect(updatable, content="3")
  update_value(StateUpdate::Set(4))
  inspect(hook_test_state(), content="4")
  update_value(StateUpdate::Update(fn(current) { current + 5 }))
  inspect(hook_test_state(), content="9")

  let memoized = use_memo_deps(fn() { 41 }, [])
  inspect(memoized, content="41")
  let callback = use_callback_deps(fn(value : Int) { value + 1 }, [])
  inspect(callback(4), content="5")
  let effect_event = use_effect_event(fn(value : Int) { value + 2 })
  inspect(effect_event(4), content="6")
  let mut callback0_calls = 0
  let callback0 = use_callback0_deps(
    fn() { callback0_calls = callback0_calls + 1 },
    [],
  )
  callback0()
  inspect(callback0_calls, content="1")

  let react_ref = use_ref("first")
  inspect(react_ref.get(), content="first")
  react_ref.set("second")
  inspect(react_ref.get(), content="second")

  let attrs = ElementAttrs::new()
  attrs.set_js_value("ref", react_ref.to_js_obscure())
  let ref_node = create_element(
      "input",
      attrs,
      ElementEvents::new(),
      style=@css.respo_style(),
      [],
    )
    .to_node()
    .to_js_obscure()
  inspect(
    react_element_prop_equals(ref_node, "ref", react_ref.to_js_obscure()),
    content="true",
  )

  let dom_ref = use_dom_ref()
  inspect(
    match dom_ref.current() {
      None => true
      Some(_) => false
    },
    content="true",
  )
  set_test_dom_ref(dom_ref.to_js_obscure(), true)
  inspect(
    match dom_ref.current() {
      Some(element) => element.tag_name() == "INPUT"
      None => false
    },
    content="true",
  )
  set_test_dom_ref(dom_ref.to_js_obscure(), false)
  inspect(
    match dom_ref.current() {
      None => true
      Some(_) => false
    },
    content="true",
  )

  let (reduced, dispatch) = use_reducer(initial=3, fn(
    state : Int,
    action : Int,
  ) {
    state + action
  })
  inspect(reduced, content="3")
  dispatch(4)
  inspect(hook_test_reduced_state(), content="7")

  let (non_default_state, dispatch_non_default) = use_reducer_with_initial(
    NonDefaultReducerState::Initial,
    fn(_state : NonDefaultReducerState, _action : Unit) {
      NonDefaultReducerState::Updated
    },
  )
  inspect(non_default_state == NonDefaultReducerState::Initial, content="true")
  dispatch_non_default(())

  let (action_state, dispatch_action, is_action_pending) = use_action_state(
    10,
    fn(state : Int, value : Int) { state + value },
  )
  inspect(action_state, content="10")
  inspect(is_action_pending, content="false")
  dispatch_action(5)
  inspect(hook_test_reduced_state(), content="15")
}

///|
test "concurrent hook wrappers preserve values and run transitions" {
  install_test_react_hooks()
  inspect(use_id(), content="moonbit-test-id")
  inspect(use_deferred_value("deferred"), content="deferred")

  let (is_pending, start) = use_transition()
  inspect(is_pending, content="false")
  let mut transition_effects = 0
  start(fn() { transition_effects = transition_effects + 1 })
  start_transition(fn() { transition_effects = transition_effects + 1 })
  inspect(transition_effects, content="2")
  inspect(hook_test_transition_action_count(), content="2")
}

///|
test "effect wrappers invoke effects and cleanup functions" {
  install_test_react_hooks()
  let mut effects = 0
  let mut cleanups = 0
  use_effect_once(fn() { effects = effects + 1 })
  use_effect_deps(fn() { effects = effects + 1 }, [])
  use_layout_effect_deps(fn() { effects = effects + 1 }, [])
  use_effect_once_with_cleanup(fn() {
    effects = effects + 1
    fn() { cleanups = cleanups + 1 }
  })
  use_layout_effect_cleanup_deps(
    fn() {
      effects = effects + 1
      fn() { cleanups = cleanups + 1 }
    },
    [],
  )
  inspect(effects, content="5")
  inspect(cleanups, content="2")
}

///|
test "components without child access render through their React factory" {
  install_test_react()
  let node = component(
    fn(_props : String) { div([Text("component body")]) },
    "props",
    [Text("React receives this child")],
  ).to_js_obscure()
  inspect(react_element_tag(node), content="div")
  inspect(react_element_child_count(node), content="1")
}

///|
struct StableComponentProps {
  label : String
}

///|
fn comp_stable_factory(props : StableComponentProps) -> VirtualNode {
  div([Text(props.label)])
}

///|
fn comp_stable_children_factory(
  _props : StableComponentProps,
  children : Array[VirtualNode],
) -> VirtualNode {
  create_element(
    "section",
    ElementAttrs::new(),
    ElementEvents::new(),
    style=@css.respo_style(),
    children,
  ).to_node()
}

///|
test "component factories keep identity across repeated renders" {
  install_component_identity_test_react()
  let first = component(comp_stable_factory, { label: "first" }, [])
  let second = component(comp_stable_factory, { label: "second" }, [])
  inspect(
    react_elements_have_same_tag(first.to_js_obscure(), second.to_js_obscure()),
    content="true",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(first.to_js_obscure()),
    ),
    content="first",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(second.to_js_obscure()),
    ),
    content="second",
  )

  let first_children = component_with_children(
    comp_stable_children_factory,
    { label: "ignored" },
    [Text("first child")],
  )
  let second_children = component_with_children(
    comp_stable_children_factory,
    { label: "ignored" },
    [Text("second child")],
  )
  inspect(
    react_elements_have_same_tag(
      first_children.to_js_obscure(),
      second_children.to_js_obscure(),
    ),
    content="true",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(first_children.to_js_obscure()),
    ),
    content="first child",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(second_children.to_js_obscure()),
    ),
    content="second child",
  )
}

///|
test "components can render their supplied MoonBit children" {
  install_test_react()
  let node = component_with_children(
    fn(_props : String, children) {
      create_element(
        "section",
        ElementAttrs::new(),
        ElementEvents::new(),
        style=@css.respo_style(),
        children,
      ).to_node()
    },
    "test",
    [Text("visible child")],
  )
  inspect(react_element_child_count(node.to_js_obscure()), content="1")
}
