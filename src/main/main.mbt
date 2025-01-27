///|
fn comp_container() -> @preact.Element {
  let attrs = @preact.ElementAttrs::new().set("id", "container")
  let event = @preact.ElementEvents::new()
  let style = @preact.ElementStyle::new()
  let children = []
  @preact.create_element("div", attrs, event, style, children)
}

///|
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  @preact.render(comp_container(), body.reinterpret_as_node())
}
