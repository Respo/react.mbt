///|
fn todos_for_test() -> Array[Todo] {
  [
    { id: 3, text: "first", completed: false },
    { id: 8, text: "second", completed: true },
  ]
}

///|
extern "js" fn install_main_test_react() -> Unit =
  #| () => {
  #|   const styleTags = [];
  #|   const runEffect = (effect) => {
  #|     const cleanup = effect();
  #|     if (typeof cleanup === "function") cleanup();
  #|   };
  #|   globalThis.window = {
  #|     document: {
  #|       head: { appendChild: (tag) => styleTags.push(tag) },
  #|       createElement: () => {
  #|         const tag = { attributes: {} };
  #|         tag.setAttribute = (key, value) => { tag.attributes[key] = value; };
  #|         return tag;
  #|       },
  #|     },
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|       useState: (initial) => [initial, () => {}],
  #|       useReducer: (_reducer, initial) => [initial, () => {}],
  #|       useEffect: runEffect,
  #|       useLayoutEffect: runEffect,
  #|       useMemo: (factory) => factory(),
  #|       useCallback: (callback) => callback,
  #|       useRef: (initial) => ({ current: initial }),
  #|     },
  #|   };
  #| }

///|
extern "js" fn main_react_element_tag(node : @dom.JsObscure) -> String =
  #| (node) => node.tag

///|
extern "js" fn main_react_element_child_count(node : @dom.JsObscure) -> Int =
  #| (node) => node.children.length

///|
extern "js" fn main_react_element_child(
  node : @dom.JsObscure,
  index : Int,
) -> @dom.JsObscure =
  #| (node, index) => node.children[index]

///|
extern "js" fn main_react_trigger_handler(
  node : @dom.JsObscure,
  handler_name : String,
) -> Unit =
  #| (node, handlerName) => node.props[handlerName]({})

///|
extern "js" fn main_react_trigger_all_handlers(node : @dom.JsObscure) -> Unit =
  #| (node) => {
  #|   const event = {
  #|     target: { value: "updated", checked: true },
  #|     key: "Enter",
  #|     preventDefault() {},
  #|     stopPropagation() {},
  #|   };
  #|   const visit = (current) => {
  #|     if (!current || typeof current !== "object") return;
  #|     for (const [key, value] of Object.entries(current.props ?? {})) {
  #|       if (key.startsWith("on") && typeof value === "function") value(event);
  #|     }
  #|     for (const child of current.children ?? []) visit(child);
  #|   };
  #|   visit(node);
  #| }

///|
test "todo reducer preserves IDs and applies every action" {
  let initial = todos_for_test()

  let added = todo_reducer(initial, AddTodo("third"))
  inspect(added.length(), content="3")
  inspect(added[2].id, content="9")
  inspect(added[2].text, content="third")
  inspect(added[2].completed, content="false")

  let toggled = todo_reducer(initial, ToggleTodo(3))
  inspect(toggled[0].completed, content="true")
  inspect(toggled[1].completed, content="true")

  let edited = todo_reducer(initial, EditTodo(8, "renamed"))
  inspect(edited[0].text, content="first")
  inspect(edited[1].text, content="renamed")
  inspect(edited[1].completed, content="true")

  let deleted = todo_reducer(initial, DeleteTodo(3))
  inspect(deleted.length(), content="1")
  inspect(deleted[0].id, content="8")

  let active = todo_reducer(initial, ClearCompleted)
  inspect(active.length(), content="1")
  inspect(active[0].id, content="3")
}

///|
test "Todo and Hooks demo components build React trees with hook runtime" {
  install_main_test_react()
  let todo_node = comp_todolist(Default::default()).to_js_obscure()
  inspect(main_react_element_tag(todo_node), content="section")
  inspect(main_react_element_child_count(todo_node), content="3")
  main_react_trigger_all_handlers(todo_node)

  let hooks_node = comp_hooks_demo(Default::default()).to_js_obscure()
  inspect(main_react_element_tag(hooks_node), content="div")
  inspect(main_react_element_child_count(hooks_node), content="4")

  let controls = main_react_element_child(hooks_node, 2)
  main_react_trigger_handler(main_react_element_child(controls, 1), "onClick")
  main_react_trigger_handler(main_react_element_child(controls, 2), "onClick")
  main_react_trigger_handler(main_react_element_child(controls, 3), "onClick")
}
