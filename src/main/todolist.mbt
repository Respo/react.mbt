///|
fnalias @css.respo_style

///|
typealias @react.VirtualNode

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
impl @react.JsValueTrait for TodoListProps with to_value(_self) -> @react.JsValue {
  @react.JsObject::new().to_value()
}

///|
impl @react.JsValueTrait for TodoListProps with from_value(
  _value : @react.JsValue,
) -> TodoListProps {
  TodoListProps::default()
}

///|
/// TodoAction 枚举类型，表示对 todos 数组的不同操作
enum TodoAction {
  /// 添加新的 todo，参数为文本内容
  AddTodo(String)
  /// 切换 todo 的完成状态，参数为 todo ID
  ToggleTodo(Int)
  /// 删除 todo，参数为 todo ID
  DeleteTodo(Int)
  /// 清除所有已完成的 todo
  ClearCompleted
}

///|
/// Todo reducer 函数，处理 todos 数组的状态变更
fn todo_reducer(todos : Array[Todo], action : TodoAction) -> Array[Todo] {
  match action {
    AddTodo(text) => {
      // 计算下一个 ID（当前最大 ID + 1）
      let next_id = todos.fold(init=0, fn(max_id, todo) {
          if todo.id > max_id {
            todo.id
          } else {
            max_id
          }
        }) +
        1
      let new_todo = { id: next_id, text, completed: false }
      let new_todos = Array::new()
      for todo in todos {
        new_todos.push(todo)
      }
      new_todos.push(new_todo)
      new_todos
    }
    ToggleTodo(id) => {
      let new_todos = Array::new()
      for todo in todos {
        if todo.id == id {
          new_todos.push({
            id: todo.id,
            text: todo.text,
            completed: not(todo.completed),
          })
        } else {
          new_todos.push(todo)
        }
      }
      new_todos
    }
    DeleteTodo(id) => {
      let new_todos = Array::new()
      for todo in todos {
        if todo.id != id {
          new_todos.push(todo)
        }
      }
      new_todos
    }
    ClearCompleted => {
      let new_todos = Array::new()
      for todo in todos {
        if not(todo.completed) {
          new_todos.push(todo)
        }
      }
      new_todos
    }
  }
}

///|
fn comp_todolist(_v : TodoListProps) -> VirtualNode {
  // 使用 use_reducer 管理 todos 数组
  let initial_todos = [
    { id: 1, text: "学习 MoonBit", completed: false },
    { id: 2, text: "构建 TodoMVC", completed: false },
    { id: 3, text: "设计数据模型", completed: true },
  ]
  let (todos, dispatch) = @react.use_reducer(
    initial=initial_todos,
    todo_reducer,
  )

  // 状态管理：当前过滤器（使用 Filter 枚举）
  let (current_filter, set_current_filter) = @react.use_state(All)

  // 状态管理：新 todo 的输入文本
  let (new_todo_text, set_new_todo_text) = @react.use_state("")

  // 计算统计数据
  let active_count = todos.filter(fn(todo) { not(todo.completed) }).length()

  // 添加新 todo 的函数
  let add_new_todo = fn() {
    let trimmed_text = new_todo_text.trim(" ")
    if trimmed_text != "" {
      dispatch(AddTodo(trimmed_text.to_string()))
      set_new_todo_text("") // 清空输入框
    }
  }

  // 切换 todo 完成状态的函数
  let toggle_todo = fn(id : Int) { dispatch(ToggleTodo(id)) }

  // 删除 todo 的函数
  let delete_todo = fn(id : Int) { dispatch(DeleteTodo(id)) }

  // 生成 todo 项的函数
  let create_todo_item = fn(index : Int, text : String, completed : Bool) {
    let checkbox_attrs = @react.ElementAttrs::new()
    if completed {
      checkbox_attrs.set("checked", "true")
    }
    @react.li(class_name=if completed { "completed" } else { "" }, [
      @react.div(class_name="view", [
        @react.input(
          class_name="toggle",
          type_=Checkbox,
          attrs=checkbox_attrs,
          on_click=fn(_event) { toggle_todo(index) },
        ),
        @react.label([@react.Text(text)]),
        @react.button(
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
  @react.section(class_name="todoapp", [
    // 头部标题
    @react.header(class_name="header", [
      @react.h1([@react.Text("todos")]),
      @react.input(
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
          let events = @react.ElementEvents::new()
          events.set(KeyDown, fn(event) {
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
    @react.section(class_name="main", [
      @react.input(id="toggle-all", class_name="toggle-all", type_=Checkbox),
      @react.label(for_="toggle-all", [@react.Text("Mark all as complete")]),
      @react.ul(class_name="todo-list", todo_items),
    ]),

    // 底部过滤器和统计
    @react.footer(class_name="footer", [
      @react.span(class_name="todo-count", [
        @react.Text(active_count.to_string() + " items left"),
      ]),
      @react.ul(class_name="filters", [
        @react.li([
          @react.a(
            class_name=if current_filter == All { "selected" } else { "" },
            href="#/",
            on_click=fn(_) { set_current_filter(All) },
            [@react.Text("All")],
          ),
        ]),
        @react.li([
          @react.a(
            class_name=if current_filter == Active { "selected" } else { "" },
            href="#/active",
            on_click=fn(_) { set_current_filter(Active) },
            [@react.Text("Active")],
          ),
        ]),
        @react.li([
          @react.a(
            class_name=if current_filter == Completed { "selected" } else { "" },
            href="#/completed",
            on_click=fn(_) { set_current_filter(Completed) },
            [@react.Text("Completed")],
          ),
        ]),
      ]),
      @react.button(
        class_name="clear-completed",
        on_click=fn(_) { dispatch(ClearCompleted) },
        [@react.Text("Clear completed")],
      ),
    ]),
  ])
}
