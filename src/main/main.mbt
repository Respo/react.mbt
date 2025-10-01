///|
struct ContainerProps {} derive(Default)

///|
impl @react.JsValueTrait for ContainerProps with to_value(_self) -> @react.JsValue {
  @react.JsObject::new().to_value()
}

///|
impl @react.JsValueTrait for ContainerProps with from_value(
  _value : @react.JsValue,
) -> ContainerProps {
  ContainerProps::default()
}

///|
fn comp_container(_v : ContainerProps) -> VirtualNode {
  let (counter, set_counter) = @react.use_state(0.0.to_float())
  @react.use_effect_once(fn() { println("comp_container mounted") })
  @react.div(
    id="container",
    style=respo_style(color=Blue, font_family="Arial", padding=10.0 |> Px),
    [
      @react.div(
        on_click=fn(_) {
          println("clicked \{counter}")
          set_counter(counter + 1.0)
        },
        class_list=[style_counter],
        [
          @react.Fragment([@react.Text("Demo: ")]),
          @react.Text("Counter \{counter}"),
        ],
      ),
      @react.component(comp_todolist, TodoListProps::default(), []),
      @react.component(comp_hooks_demo, HooksDemoProps::default(), []),
    ],
  )
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = ContainerProps::default()
  @react.render(@react.component(comp_container, props, []), body)
  println("loaded")
}

///|
let style_counter : String = @react.static_style([
  ("&", respo_style(margin_bottom=20.0 |> Px, padding=10.0 |> Px)),
])
