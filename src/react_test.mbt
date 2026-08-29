///|
extern "js" fn install_test_react() -> Unit =
  #| () => {
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|     },
  #|   };
  #| }

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
extern "js" fn js_value_string_prop(
  value : @dom.JsObscure,
  key : String,
) -> String =
  #| (value, key) => value[key] || ""

///|
extern "js" fn react_element_tag(node : @dom.JsObscure) -> String =
  #| (node) => node.tag

///|
extern "js" fn react_element_bool_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => node.props[key] === true

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
  #|   target: { value: "updated value" },
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
  #|   globalThis.__moonbitHookState = { state: null, reduced: null };
  #|   const runEffect = (effect) => {
  #|     const cleanup = effect();
  #|     if (typeof cleanup === "function") cleanup();
  #|   };
  #|   globalThis.window = {
  #|     React: {
  #|       useState: (initial) => [initial, (value) => {
  #|         globalThis.__moonbitHookState.state = value;
  #|       }],
  #|       useEffect: runEffect,
  #|       useLayoutEffect: runEffect,
  #|       useMemo: (factory) => factory(),
  #|       useCallback: (callback) => callback,
  #|       useRef: (initial) => ({ current: initial }),
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
test "DOM events use React handler names" {
  inspect(dom_event_to_react_handler(Click), content="onClick")
  inspect(dom_event_to_react_handler(KeyDown), content="onKeyDown")
  inspect(dom_event_to_react_handler(TouchCancel), content="onTouchCancel")
  inspect(DOMEventType::Click.to_string(), content="click")
}

///|
test "all DOM event types map to native and React names" {
  let cases : Array[(DOMEventType, String, String)] = [
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
    (DOMEventType::KeyDown, "keydown", "onKeyDown"),
    (DOMEventType::KeyUp, "keyup", "onKeyUp"),
    (DOMEventType::KeyPress, "keypress", "onKeyPress"),
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
test "attributes set through ElementAttrs are converted to React props" {
  install_test_react()
  let attrs = ElementAttrs::new().add("title", "first")
  attrs.set("title", "updated")
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
test "element helpers preserve form, link, and media props" {
  install_test_react()

  let label_node = label(for_="email", []).to_js_obscure()
  inspect(react_element_tag(label_node), content="label")
  inspect(react_element_string_prop(label_node, "htmlFor"), content="email")

  let input_node = input(
    type_=Checkbox,
    value="accepted",
    placeholder="accept terms",
    disabled=true,
  ).to_js_obscure()
  inspect(react_element_tag(input_node), content="input")
  inspect(react_element_string_prop(input_node, "type"), content="checkbox")
  inspect(react_element_bool_prop(input_node, "disabled"), content="true")

  let link_node = a(href="/docs", target="_blank", [Text("docs")]).to_js_obscure()
  inspect(react_element_tag(link_node), content="a")
  inspect(react_element_string_prop(link_node, "href"), content="/docs")
  inspect(react_element_string_prop(link_node, "target"), content="_blank")

  let media_node = video(
    src="movie.mp4",
    controls=true,
    autoplay=true,
    loop_enabled=true,
    muted=true,
    [],
  ).to_js_obscure()
  inspect(react_element_tag(media_node), content="video")
  inspect(react_element_bool_prop(media_node, "controls"), content="true")
  inspect(react_element_bool_prop(media_node, "autoPlay"), content="true")
  inspect(react_element_bool_prop(media_node, "loop"), content="true")
  inspect(react_element_bool_prop(media_node, "muted"), content="true")

  let audio_node = audio(
    src="sound.mp3",
    controls=true,
    autoplay=true,
    loop_enabled=true,
    muted=true,
    [],
  ).to_js_obscure()
  inspect(react_element_tag(audio_node), content="audio")
  inspect(react_element_bool_prop(audio_node, "controls"), content="true")
  inspect(react_element_bool_prop(audio_node, "autoPlay"), content="true")
  inspect(react_element_bool_prop(audio_node, "loop"), content="true")
  inspect(react_element_bool_prop(audio_node, "muted"), content="true")

  let select_node = select(value="second", disabled=true, multiple=true, []).to_js_obscure()
  inspect(react_element_string_prop(select_node, "value"), content="second")
  inspect(react_element_bool_prop(select_node, "disabled"), content="true")
  inspect(react_element_bool_prop(select_node, "multiple"), content="true")

  let option_node = option(value="second", selected=true, disabled=true, []).to_js_obscure()
  inspect(react_element_string_prop(option_node, "value"), content="second")
  inspect(react_element_bool_prop(option_node, "selected"), content="true")
  inspect(react_element_bool_prop(option_node, "disabled"), content="true")

  let textarea_node = textarea(rows=3, cols=20).to_js_obscure()
  inspect(react_element_int_prop(textarea_node, "rows"), content="3")
  inspect(react_element_int_prop(textarea_node, "cols"), content="20")
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

  let memoized = use_memo_deps(fn() { 41 }, [])
  inspect(memoized, content="41")
  let callback = use_callback_deps(fn(value : Int) { value + 1 }, [])
  inspect(callback(4), content="5")
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
  let direct_ref = ReactRef::from("direct")
  inspect(direct_ref.get(), content="direct")

  let (reduced, dispatch) = use_reducer(initial=3, fn(
    state : Int,
    action : Int,
  ) {
    state + action
  })
  inspect(reduced, content="3")
  dispatch(4)
  inspect(hook_test_reduced_state(), content="7")
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
