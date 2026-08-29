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
extern "js" fn react_element_tag(node : @dom.JsObscure) -> String =
  #| (node) => node.tag

///|
extern "js" fn react_element_bool_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => node.props[key] === true

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
}

///|
test "DOM events use React handler names" {
  inspect(dom_event_to_react_handler(Click), content="onClick")
  inspect(dom_event_to_react_handler(KeyDown), content="onKeyDown")
  inspect(dom_event_to_react_handler(TouchCancel), content="onTouchCancel")
  inspect(DOMEventType::Click.to_string(), content="click")
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

  let textarea_node = textarea(rows=3, cols=20).to_js_obscure()
  inspect(react_element_int_prop(textarea_node, "rows"), content="3")
  inspect(react_element_int_prop(textarea_node, "cols"), content="20")
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
