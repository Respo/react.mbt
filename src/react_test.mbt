///|
extern "js" fn install_test_react() -> Unit =
  #| () => {
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) => ({ tag, props, children }),
  #|     },
  #|   };
  #| }

///|
extern "js" fn react_element_child_count(node : @dom.JsObscure) -> Int =
  #| (node) => node.children.length

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
