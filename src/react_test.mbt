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
test "DOM attribute names use React property names" {
  inspect(dom_attr_to_react_prop("class"), content="className")
  inspect(dom_attr_to_react_prop("for"), content="htmlFor")
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
