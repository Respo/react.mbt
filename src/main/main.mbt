///|
fnalias @preact.component

///|
fnalias @css.respo_style

///|
typealias @preact.VirtualNode

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
  // println("counter: \{counter}")
  @preact.div(
    id="container",
    style=respo_style(color=Blue, font_family="Arial", padding=10.0 |> Px),
    on_click=fn(_) {
      println("clicked \{counter}")
      set_counter(counter + 1.0)
    },
    [Fragment([Text("Demo: ")]), Text("Counter \{counter}")],
  )
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = ContainerProps::default()
  @preact.render(
    component(comp_container, props, []),
    body,
  )
  println("loaded")
}
