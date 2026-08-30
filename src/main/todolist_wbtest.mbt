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
  #|   let renderCalls = 0;
  #|   const hookValues = [];
  #|   let hookIndex = 0;
  #|   const nextHookIndex = (initial) => {
  #|     const index = hookIndex++;
  #|     if (index === hookValues.length) hookValues.push(initial);
  #|     return index;
  #|   };
  #|   const runEffect = (effect) => {
  #|     const cleanup = effect();
  #|     if (typeof cleanup === "function") cleanup();
  #|   };
  #|   globalThis.window = {
  #|     document: {
  #|       head: { appendChild: (tag) => styleTags.push(tag) },
  #|       body: () => ({}),
  #|       createElement: () => {
  #|         const tag = { attributes: {} };
  #|         tag.setAttribute = (key, value) => { tag.attributes[key] = value; };
  #|         return tag;
  #|       },
  #|     },
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createContext: (defaultValue) => ({ defaultValue, currentValue: defaultValue }),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|       useState: (initial) => {
  #|         const index = nextHookIndex(initial);
  #|         return [hookValues[index], (value) => {
  #|           hookValues[index] = typeof value === "function" ? value(hookValues[index]) : value;
  #|         }];
  #|       },
  #|       useReducer: (reducer, initial) => {
  #|         const index = nextHookIndex(initial);
  #|         return [hookValues[index], (action) => { hookValues[index] = reducer(hookValues[index], action); }];
  #|       },
  #|       useActionState: (action, initial) => {
  #|         const index = nextHookIndex(initial);
  #|         return [hookValues[index], (value) => { hookValues[index] = action(hookValues[index], value); }, false];
  #|       },
  #|       useEffect: runEffect,
  #|       useLayoutEffect: runEffect,
  #|       useMemo: (factory) => factory(),
  #|       useCallback: (callback) => callback,
  #|       useContext: (context) => context.currentValue,
  #|       useEffectEvent: (callback) => callback,
  #|       startTransition: (action) => action(),
  #|       useRef: (initial) => ({ current: initial }),
  #|     },
  #|     ReactDOMClient: {
  #|       createRoot: () => ({ render: () => { renderCalls += 1; } }),
  #|     },
  #|   };
  #|   globalThis.__moonbitMainRenderCalls = () => renderCalls;
  #|   globalThis.__moonbitResetMainHooks = () => { hookIndex = 0; };
  #| }

///|
extern "js" fn main_react_element_tag(node : @dom.JsObscure) -> String =
  #| (node) => node.tag

///|
extern "js" fn main_react_string_prop(
  node : @dom.JsObscure,
  key : String,
) -> String =
  #| (node, key) => node.props[key] || ""

///|
extern "js" fn main_render_call_count() -> Int =
  #| () => globalThis.__moonbitMainRenderCalls()

///|
extern "js" fn reset_main_hooks() -> Unit =
  #| () => globalThis.__moonbitResetMainHooks()

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
  #| (node, handlerName) => node.props[handlerName]({
  #|   preventDefault() {},
  #|   stopPropagation() {},
  #| })

///|
extern "js" fn main_react_trigger_event(
  node : @dom.JsObscure,
  handler_name : String,
  value : String,
  key : String,
) -> Unit =
  #| (node, handlerName, value, key) => node.props[handlerName]({
  #|   target: { value, checked: true },
  #|   key,
  #|   preventDefault() {},
  #|   stopPropagation() {},
  #| })

///|
extern "js" fn main_react_tree_contains(
  node : @dom.JsObscure,
  text : String,
) -> Bool =
  #| (node, text) => {
  #|   const contains = (current) => {
  #|     if (current === text) return true;
  #|     if (!current || typeof current !== "object") return false;
  #|     return (current.children ?? []).some(contains);
  #|   };
  #|   return contains(node);
  #| }

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

  let added_to_unsorted = todo_reducer(
    [
      { id: 8, text: "last", completed: false },
      { id: 3, text: "first", completed: false },
    ],
    AddTodo("new"),
  )
  inspect(added_to_unsorted[2].id, content="9")

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

  let all_completed = todo_reducer(initial, SetAllCompleted(true))
  inspect(all_completed[0].completed, content="true")
  inspect(all_completed[1].completed, content="true")

  let all_active = todo_reducer(initial, SetAllCompleted(false))
  inspect(all_active[0].completed, content="false")
  inspect(all_active[1].completed, content="false")

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
  inspect(main_react_element_child_count(hooks_node), content="5")

  let controls = main_react_element_child(hooks_node, 2)
  main_react_trigger_handler(main_react_element_child(controls, 1), "onClick")
  main_react_trigger_handler(main_react_element_child(controls, 2), "onClick")
  main_react_trigger_handler(main_react_element_child(controls, 3), "onClick")
  main_react_trigger_handler(main_react_element_child(controls, 4), "onClick")
}

///|
test "Hooks demo reflects state after a rerender" {
  install_main_test_react()
  reset_main_hooks()
  let initial_tree = comp_hooks_demo(Default::default()).to_js_obscure()
  let controls = main_react_element_child(initial_tree, 2)
  main_react_trigger_handler(main_react_element_child(controls, 1), "onClick")
  main_react_trigger_handler(main_react_element_child(controls, 3), "onClick")

  reset_main_hooks()
  let updated_tree = comp_hooks_demo(Default::default()).to_js_obscure()
  inspect(
    main_react_tree_contains(updated_tree, "当前计数: 1"),
    content="true",
  )
  reset_main_hooks()
  let effect_tree = comp_hooks_demo(Default::default()).to_js_obscure()
  inspect(
    main_react_tree_contains(effect_tree, "消息: 定时器已更新到: 1"),
    content="true",
  )
}

///|
test "the application container renders after server-side module evaluation" {
  install_main_test_react()
  let container_node = comp_container(Default::default()).to_js_obscure()
  inspect(main_react_element_tag(container_node), content="div")
  inspect(main_react_element_child_count(container_node), content="3")
  main_react_trigger_all_handlers(container_node)
}

///|
test "Todo editing handlers update the rerendered component tree" {
  install_main_test_react()
  reset_main_hooks()
  let initial_tree = comp_todolist(Default::default()).to_js_obscure()
  let initial_list = main_react_element_child(
    main_react_element_child(initial_tree, 1),
    2,
  )
  let initial_view = main_react_element_child(
    main_react_element_child(initial_list, 0),
    0,
  )
  main_react_trigger_event(
    main_react_element_child(initial_view, 1),
    "onDoubleClick",
    "",
    "",
  )

  reset_main_hooks()
  let editing_tree = comp_todolist(Default::default()).to_js_obscure()
  let editing_list = main_react_element_child(
    main_react_element_child(editing_tree, 1),
    2,
  )
  let editing_item = main_react_element_child(editing_list, 0)
  inspect(main_react_string_prop(editing_item, "className"), content="editing")
  main_react_trigger_event(
    main_react_element_child(editing_item, 0),
    "onInput",
    "editing todo",
    "",
  )

  reset_main_hooks()
  let input_tree = comp_todolist(Default::default()).to_js_obscure()
  let input_list = main_react_element_child(
    main_react_element_child(input_tree, 1),
    2,
  )
  main_react_trigger_event(
    main_react_element_child(main_react_element_child(input_list, 0), 0),
    "onKeyDown",
    "",
    "Tab",
  )
  main_react_trigger_event(
    main_react_element_child(main_react_element_child(input_list, 0), 0),
    "onChange",
    "updated todo",
    "",
  )

  reset_main_hooks()
  let changed_tree = comp_todolist(Default::default()).to_js_obscure()
  let changed_list = main_react_element_child(
    main_react_element_child(changed_tree, 1),
    2,
  )
  main_react_trigger_event(
    main_react_element_child(main_react_element_child(changed_list, 0), 0),
    "onKeyDown",
    "",
    "Enter",
  )

  reset_main_hooks()
  let saved_tree = comp_todolist(Default::default()).to_js_obscure()
  inspect(main_react_tree_contains(saved_tree, "updated todo"), content="true")

  let saved_list = main_react_element_child(
    main_react_element_child(saved_tree, 1),
    2,
  )
  let saved_view = main_react_element_child(
    main_react_element_child(saved_list, 0),
    0,
  )
  main_react_trigger_event(
    main_react_element_child(saved_view, 1),
    "onDoubleClick",
    "",
    "",
  )
  reset_main_hooks()
  let cancel_tree = comp_todolist(Default::default()).to_js_obscure()
  let cancel_list = main_react_element_child(
    main_react_element_child(cancel_tree, 1),
    2,
  )
  main_react_trigger_event(
    main_react_element_child(main_react_element_child(cancel_list, 0), 0),
    "onKeyDown",
    "",
    "Escape",
  )
  reset_main_hooks()
  let cancelled_tree = comp_todolist(Default::default()).to_js_obscure()
  let cancelled_list = main_react_element_child(
    main_react_element_child(cancelled_tree, 1),
    2,
  )
  inspect(
    main_react_string_prop(
      main_react_element_child(cancelled_list, 0),
      "className",
    ),
    content="",
  )
}

///|
test "Todo creation and active filter update the rerendered component tree" {
  install_main_test_react()
  reset_main_hooks()
  let initial_tree = comp_todolist(Default::default()).to_js_obscure()
  let header = main_react_element_child(initial_tree, 0)
  main_react_trigger_event(
    main_react_element_child(header, 1),
    "onInput",
    "new task",
    "",
  )

  reset_main_hooks()
  let typed_tree = comp_todolist(Default::default()).to_js_obscure()
  main_react_trigger_event(
    main_react_element_child(main_react_element_child(typed_tree, 0), 1),
    "onKeyDown",
    "",
    "Enter",
  )

  reset_main_hooks()
  let added_tree = comp_todolist(Default::default()).to_js_obscure()
  inspect(main_react_tree_contains(added_tree, "new task"), content="true")
  let filters = main_react_element_child(
    main_react_element_child(added_tree, 2),
    1,
  )
  main_react_trigger_handler(
    main_react_element_child(main_react_element_child(filters, 1), 0),
    "onClick",
  )

  reset_main_hooks()
  let active_tree = comp_todolist(Default::default()).to_js_obscure()
  let active_list = main_react_element_child(
    main_react_element_child(active_tree, 1),
    2,
  )
  inspect(main_react_element_child_count(active_list), content="3")

  let active_filters = main_react_element_child(
    main_react_element_child(active_tree, 2),
    1,
  )
  main_react_trigger_handler(
    main_react_element_child(main_react_element_child(active_filters, 2), 0),
    "onClick",
  )
  reset_main_hooks()
  let completed_tree = comp_todolist(Default::default()).to_js_obscure()
  let completed_list = main_react_element_child(
    main_react_element_child(completed_tree, 1),
    2,
  )
  inspect(main_react_element_child_count(completed_list), content="1")
}

///|
test "the application entry point renders its root" {
  install_main_test_react()
  run_app()
  inspect(main_render_call_count(), content="1")
}
