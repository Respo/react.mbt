///|
fn todos_for_test() -> Array[Todo] {
  [
    { id: 3, text: "first", completed: false },
    { id: 8, text: "second", completed: true },
  ]
}

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
