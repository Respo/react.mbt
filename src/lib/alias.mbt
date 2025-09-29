///|
pub fn div(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  innerHTML? : String,
  on_click? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = if attrs is Some(attrs) { attrs } else { ElementAttrs::new() }
  let event = if event is Some(event) { event } else { ElementEvents::new() }
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  if on_click is Some(on_click) {
    event.set("click", on_click)
  }
  Element({ name: "div", attrs, event, style, children })
}

///|
/// Combines a base class name with a list of additional class names into a
/// single string, with class names separated by spaces. Returns `None` if both
/// inputs are empty.
fn combile_classes(class_name : String?, class_list : Array[String]) -> String? {
  let mut class_content = ""
  if class_name is Some(class_name) {
    class_content += " " + class_name
  }
  if not(class_list.is_empty()) {
    for class_name in class_list {
      class_content += " " + class_name
    }
  }
  class_content = class_content.trim(" ").to_string()
  if class_content.is_empty() {
    None
  } else {
    Some(class_content)
  }
}
