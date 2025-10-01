///|
struct ContainerProps {} derive(Default)

///|
impl @preact.JsValueTrait for ContainerProps with to_value(_self) -> @preact.JsValue {
  @preact.JsObject::new().to_value()
}

///|
impl @preact.JsValueTrait for ContainerProps with from_value(
  _value : @preact.JsValue,
) -> ContainerProps {
  ContainerProps::default()
}

///|
fn comp_container(_v : ContainerProps) -> VirtualNode {
  let (counter, set_counter) = @preact.use_state(0.0.to_float())
  @preact.use_effect_once(fn() { println("comp_container mounted") })
  // println("counter: \{counter}")
  @preact.div(
    id="container",
    style=respo_style(color=Blue, font_family="Arial", padding=10.0 |> Px),
    [
      // 原有的 counter 演示
      @preact.div(
        on_click=fn(_) {
          println("clicked \{counter}")
          set_counter(counter + 1.0)
        },
        class_list=[style_counter],
        [Fragment([Text("Demo: ")]), Text("Counter \{counter}")],
      ),

      // 添加 Todolist 组件
      component(comp_todolist, TodoListProps::default(), []),
      
      // 添加 Hooks Demo 组件
      component(comp_hooks_demo, HooksDemoProps::default(), []),
    ],
  )
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = ContainerProps::default()
  @preact.render(component(comp_container, props, []), body)
  println("loaded")
}

///|
let style_counter : String = @preact.static_style([
  ("&", respo_style(margin_bottom=20.0 |> Px, padding=10.0 |> Px)),
])
