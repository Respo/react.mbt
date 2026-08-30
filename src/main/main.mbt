///|
struct ContainerProps {} derive(Default)

///|
fn comp_container(_v : ContainerProps) -> VirtualNode {
  let (counter, set_counter) = @react.use_state(Float::from_double(0.0))
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
        [Fragment([Text("Demo: ")]), Text("Counter \{counter}")],
      ),
      @react.component(comp_todolist, Default::default(), []),
      @react.component(comp_hooks_demo, Default::default(), []),
    ],
  )
}

///|
fn run_app() -> Unit {
  let window = @dom.window()
  let doc = window.document()
  let root = match doc.get_element_by_id("root") {
    Some(root) => root
    None => doc.body()
  }
  let props : ContainerProps = Default::default()
  @react.render(@react.component(comp_container, props, []), root)
  println("loaded")
}

///|
fn main {
  run_app()
  run_conformance()
  run_store_component_conformance()
  run_generated_dom_conformance()
}

///|
let style_counter : String = @react.static_style([
  ("&", respo_style(margin_bottom=20.0 |> Px, padding=10.0 |> Px)),
])
