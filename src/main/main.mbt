///|
fnalias @preact.connect

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
  let attrs = @preact.ElementAttrs::new().set("id", "container")
  let event = @preact.ElementEvents::new().set("click", fn(_) {
    println("clicked \{counter}")
    set_counter(counter + 1.0)
  })
  let style = @preact.ElementStyle::new()
    .set("color", "blue")
    .set("font-family", "Arial")
    .set("padding", "10px")
  @preact.create_element("div", attrs, event, style, [
    VirtualNode::fragment([VirtualNode::text("Demo: ")]),
    VirtualNode::text("Counter \{counter}"),
  ]).to_node()
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = ContainerProps::default()
  @preact.render(
    connect(comp_container, props, []).to_js_value(),
    // comp_container(@preact.JsObject::new().to_value()),
    body.reinterpret_as_node(),
  )
  println("loaded")
}
