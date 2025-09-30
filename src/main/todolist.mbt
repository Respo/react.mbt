///|
fnalias @preact.component

///|
fnalias @css.respo_style

///|
typealias @preact.VirtualNode

///|
typealias @preact.InputType

///|
// Todo 项的数据结构
struct Todo {
  id : Int
  text : String
  completed : Bool
} derive(Default)

///|
// 过滤器枚举
enum Filter {
  All
  Active
  Completed
} derive(Eq)

///|
// TodoList 组件的 Props
struct TodoListProps {} derive(Default)

///|
impl @preact.JsValueTrait for TodoListProps with to_value(_self) -> @preact.JsValue {
  @preact.JsObject::new().to_value()
}

///|
impl @preact.JsValueTrait for TodoListProps with from_value(
  _value : @preact.JsValue,
) -> TodoListProps {
  TodoListProps::default()
}

///|
fn comp_todolist(_v : TodoListProps) -> VirtualNode {
  // 状态管理：todo 列表
  let (todos, set_todos) = @preact.use_state([
    { id: 1, text: "学习 MoonBit", completed: false },
    { id: 2, text: "构建 TodoMVC", completed: false },
    { id: 3, text: "设计数据模型", completed: true },
  ])

  // 状态管理：当前过滤器（使用 Filter 枚举）
  let (current_filter, set_current_filter) = @preact.use_state(All)

  // 状态管理：新 todo 的输入文本
  let (new_todo_text, set_new_todo_text) = @preact.use_state("")

  // 状态管理：下一个 todo 的 ID
  let (next_id, set_next_id) = @preact.use_state(4)

  // 计算统计数据
  let active_count = todos.filter(fn(todo) { not(todo.completed) }).length()
  let completed_count = todos.filter(fn(todo) { todo.completed }).length()

  // 添加新 todo 的函数
  let add_new_todo = fn() {
    let trimmed_text = new_todo_text.trim(" ")
    if trimmed_text != "" {
      let new_todo = {
        id: next_id,
        text: trimmed_text.to_string(),
        completed: false,
      }
      set_todos([new_todo, ..todos])
      set_next_id(next_id + 1)
      set_new_todo_text("") // 清空输入框
    }
  }

  // 切换 todo 完成状态的函数
  let toggle_todo = fn(id : Int) {
    let updated_todos = todos.map(fn(todo) {
      if todo.id == id {
        { id: todo.id, text: todo.text, completed: not(todo.completed) }
      } else {
        todo
      }
    })
    set_todos(updated_todos)
  }

  // 删除 todo 的函数
  let delete_todo = fn(id : Int) {
    let filtered_todos = todos.filter(fn(todo) { todo.id != id })
    set_todos(filtered_todos)
  }

  // 生成 todo 项的函数
  let create_todo_item = fn(index : Int, text : String, completed : Bool) {
    let checkbox_attrs = @preact.ElementAttrs::new()
    if completed {
      checkbox_attrs.set("checked", "true")
    }
    @preact.li(class_name=if completed { "completed" } else { "" }, [
      @preact.div(class_name="view", [
        @preact.input(
          class_name="toggle",
          type_=InputType::Checkbox,
          attrs=checkbox_attrs,
          on_click=fn(_event) { toggle_todo(index) },
        ),
        @preact.label([Text(text)]),
        @preact.button(
          class_name="destroy",
          on_click=fn(_event) { delete_todo(index) },
          [],
        ),
      ]),
    ])
  }

  // 根据 current_filter 过滤 todos
  let filtered_todos = match current_filter {
    Active => todos.filter(fn(todo) { not(todo.completed) })
    Completed => todos.filter(fn(todo) { todo.completed })
    All => todos // 显示所有
  }

  // 生成 todo 项列表
  let todo_items = {
    let items = []
    let mut i = 0
    while i < filtered_todos.length() {
      let todo = filtered_todos[i]
      items.push(create_todo_item(todo.id, todo.text, todo.completed))
      i = i + 1
    }
    items
  }
  println("rerender triggered")
  @preact.section(class_name="todoapp", [
    // 头部标题
    @preact.header(class_name="header", [
      @preact.h1([Text("todos")]),
      @preact.input(
        class_name="new-todo",
        placeholder="What needs to be done?",
        value=new_todo_text,
        on_input=fn(event) {
          let value = event.target_value()
          set_new_todo_text(value)
        },
        on_change=fn(event) {
          let value = event.target_value()
          set_new_todo_text(value)
        },
        event={
          let events = @preact.ElementEvents::new()
          events.set("keydown", fn(event) {
            // 检查是否按下了回车键
            if event.key() == "Enter" {
              add_new_todo()
            }
          })
          events
        },
      ),
    ]),

    // 主要内容区域
    @preact.section(class_name="main", [
      @preact.input(id="toggle-all", class_name="toggle-all", type_=Checkbox),
      @preact.label(for_="toggle-all", [Text("Mark all as complete")]),
      @preact.ul(class_name="todo-list", todo_items),
    ]),

    // 底部过滤器和统计
    @preact.footer(class_name="footer", [
      @preact.span(class_name="todo-count", [
        Text(active_count.to_string() + " items left"),
      ]),
      @preact.ul(class_name="filters", [
        @preact.li([
          @preact.a(
            class_name=if current_filter == All { "selected" } else { "" },
            href="#/",
            on_click=fn(_) { set_current_filter(All) },
            [Text("All")],
          ),
        ]),
        @preact.li([
          @preact.a(
            class_name=if current_filter == Active { "selected" } else { "" },
            href="#/active",
            on_click=fn(_) { set_current_filter(Active) },
            [Text("Active")],
          ),
        ]),
        @preact.li([
          @preact.a(
            class_name=if current_filter == Completed { "selected" } else { "" },
            href="#/completed",
            on_click=fn(_) { set_current_filter(Completed) },
            [Text("Completed")],
          ),
        ]),
      ]),
      @preact.button(
        class_name="clear-completed",
        on_click=fn(_) {
          set_todos(todos.filter(fn(todo) { not(todo.completed) }))
        },
        [Text("Clear completed")],
      ),
    ]),
  ])
}
