///|
fn comp_container(v : @preact.JsValue) -> @preact.JsValue {
  let (counter, set_counter) = @preact.use_state(0.0.to_float())
  // println("counter: \{counter}")
  let attrs = @preact.ElementAttrs::new().set("id", "container")
  let event = @preact.ElementEvents::new().set("click", fn(_) {
    println("clicked \{counter}")
    set_counter(counter + 1.0)
  })
  let style = @preact.ElementStyle::new()
  let children : Array[@preact.Node] = []
  children.push(@preact.Node::text("Counter \{counter}"))
  @preact.create_element("div", attrs, event, style, children)
  .to_node()
  .to_js_value()
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = @preact.JsValue::from_object(@preact.JsObject::new())
  @preact.render(
    @preact.create_factory(comp_container, props, @preact.JsArray::new()),
    // comp_container(@preact.JsObject::new().to_value()),
    body.reinterpret_as_node(),
  )
  println("loaded")
}
