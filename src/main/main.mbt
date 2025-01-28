///|
fn comp_container() -> @preact.Element {
  // let (counter, set_counter) = @preact.use_state(0.0.to_float())
  let attrs = @preact.ElementAttrs::new().set("id", "container")
  let event = @preact.ElementEvents::new()
  let style = @preact.ElementStyle::new()
  let children : Array[@preact.Node] = []
  children.push(@preact.Node::text("Counter 1"))
  @preact.create_element("div", attrs, event, style, children)
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  @preact.render(comp_container(), body.reinterpret_as_node())
}
