///|
///|
pub fn span(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "span", attrs, event, style, children })
}

///|
pub fn p(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "p", attrs, event, style, children })
}

///|
pub fn h1(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "h1", attrs, event, style, children })
}

///|
pub fn h2(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "h2", attrs, event, style, children })
}

///|
pub fn h3(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "h3", attrs, event, style, children })
}

///|
pub fn h4(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "h4", attrs, event, style, children })
}

///|
pub fn h5(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "h5", attrs, event, style, children })
}

///|
pub fn h6(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "h6", attrs, event, style, children })
}

///|
pub fn a(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  innerHTML? : String,
  href? : String,
  target? : String,
  on_click? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  if href is Some(href) {
    attrs.set("href", href)
  }
  if target is Some(target) {
    attrs.set("target", target)
  }
  if on_click is Some(on_click) {
    event.set("click", on_click)
  }
  Element({ name: "a", attrs, event, style, children })
}

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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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

///|
pub fn input(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  input_type? : String,
  value? : String,
  placeholder? : String,
  disabled? : Bool,
  on_click? : (DOMEvent) -> Unit,
  on_change? : (DOMEvent) -> Unit,
  on_input? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if input_type is Some(input_type) {
    attrs.set("type", input_type)
  }
  if value is Some(value) {
    attrs.set("value", value)
  }
  if placeholder is Some(placeholder) {
    attrs.set("placeholder", placeholder)
  }
  if disabled is Some(true) {
    attrs.set("disabled", "true")
  }
  if on_click is Some(on_click) {
    event.set("click", on_click)
  }
  if on_change is Some(on_change) {
    event.set("change", on_change)
  }
  if on_input is Some(on_input) {
    event.set("input", on_input)
  }
  Element({ name: "input", attrs, event, style, children: [] })
}

///|
pub fn button(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  innerHTML? : String,
  button_type? : String,
  disabled? : Bool,
  on_click? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  if button_type is Some(button_type) {
    attrs.set("type", button_type)
  }
  if disabled is Some(true) {
    attrs.set("disabled", "true")
  }
  if on_click is Some(on_click) {
    event.set("click", on_click)
  }
  Element({ name: "button", attrs, event, style, children })
}

///|
pub fn textarea(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  value? : String,
  placeholder? : String,
  rows? : Int,
  cols? : Int,
  disabled? : Bool,
  on_change? : (DOMEvent) -> Unit,
  on_input? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if value is Some(value) {
    attrs.set("value", value)
  }
  if placeholder is Some(placeholder) {
    attrs.set("placeholder", placeholder)
  }
  if rows is Some(rows) {
    attrs.set("rows", rows.to_string())
  }
  if cols is Some(cols) {
    attrs.set("cols", cols.to_string())
  }
  if disabled is Some(true) {
    attrs.set("disabled", "true")
  }
  if on_change is Some(on_change) {
    event.set("change", on_change)
  }
  if on_input is Some(on_input) {
    event.set("input", on_input)
  }
  Element({ name: "textarea", attrs, event, style, children: [] })
}

///|
pub fn select(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  value? : String,
  disabled? : Bool,
  multiple? : Bool,
  on_change? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if value is Some(value) {
    attrs.set("value", value)
  }
  if disabled is Some(true) {
    attrs.set("disabled", "true")
  }
  if multiple is Some(true) {
    attrs.set("multiple", "true")
  }
  if on_change is Some(on_change) {
    event.set("change", on_change)
  }
  Element({ name: "select", attrs, event, style, children })
}

///|
pub fn option(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  innerHTML? : String,
  value? : String,
  selected? : Bool,
  disabled? : Bool,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if innerHTML is Some(innerHTML) {
    attrs.set("innerHTML", innerHTML)
  }
  if value is Some(value) {
    attrs.set("value", value)
  }
  if selected is Some(true) {
    attrs.set("selected", "true")
  }
  if disabled is Some(true) {
    attrs.set("disabled", "true")
  }
  Element({ name: "option", attrs, event, style, children })
}

///|
pub fn section(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "section", attrs, event, style, children })
}

///|
pub fn article(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "article", attrs, event, style, children })
}

///|
pub fn header(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "header", attrs, event, style, children })
}

///|
pub fn footer(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "footer", attrs, event, style, children })
}

///|
pub fn nav(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "nav", attrs, event, style, children })
}

///|
pub fn aside(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "aside", attrs, event, style, children })
}

///|
pub fn ul(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "ul", attrs, event, style, children })
}

///|
pub fn ol(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "ol", attrs, event, style, children })
}

///|
pub fn li(
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
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
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
  Element({ name: "li", attrs, event, style, children })
}

///|
pub fn img(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  src? : String,
  alt? : String,
  width? : String,
  height? : String,
  on_click? : (DOMEvent) -> Unit,
  on_load? : (DOMEvent) -> Unit,
  on_error? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if src is Some(src) {
    attrs.set("src", src)
  }
  if alt is Some(alt) {
    attrs.set("alt", alt)
  }
  if width is Some(width) {
    attrs.set("width", width)
  }
  if height is Some(height) {
    attrs.set("height", height)
  }
  if on_click is Some(on_click) {
    event.set("click", on_click)
  }
  if on_load is Some(on_load) {
    event.set("load", on_load)
  }
  if on_error is Some(on_error) {
    event.set("error", on_error)
  }
  Element({ name: "img", attrs, event, style, children: [] })
}

///|
pub fn video(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  src? : String,
  controls? : Bool,
  autoplay? : Bool,
  loop_enabled? : Bool,
  muted? : Bool,
  width? : String,
  height? : String,
  on_click? : (DOMEvent) -> Unit,
  on_play? : (DOMEvent) -> Unit,
  on_pause? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if src is Some(src) {
    attrs.set("src", src)
  }
  if controls is Some(true) {
    attrs.set("controls", "true")
  }
  if autoplay is Some(true) {
    attrs.set("autoplay", "true")
  }
  if loop_enabled is Some(true) {
    attrs.set("loop", "true")
  }
  if muted is Some(true) {
    attrs.set("muted", "true")
  }
  if width is Some(width) {
    attrs.set("width", width)
  }
  if height is Some(height) {
    attrs.set("height", height)
  }
  if on_click is Some(on_click) {
    event.set("click", on_click)
  }
  if on_play is Some(on_play) {
    event.set("play", on_play)
  }
  if on_pause is Some(on_pause) {
    event.set("pause", on_pause)
  }
  Element({ name: "video", attrs, event, style, children })
}

///|
pub fn audio(
  id? : String,
  class_name? : String,
  class_list? : Array[String] = [],
  attrs? : ElementAttrs,
  event? : ElementEvents,
  style? : RespoStyle = respo_style(),
  children : Array[VirtualNode],
  src? : String,
  controls? : Bool,
  autoplay? : Bool,
  loop_enabled? : Bool,
  muted? : Bool,
  on_play? : (DOMEvent) -> Unit,
  on_pause? : (DOMEvent) -> Unit,
) -> VirtualNode {
  let attrs = attrs.unwrap_or_default()
  let event = event.unwrap_or_default()
  if id is Some(id) {
    attrs.set("id", id)
  }
  if combile_classes(class_name, class_list) is Some(class_name) {
    attrs.set("class", class_name)
  }
  if src is Some(src) {
    attrs.set("src", src)
  }
  if controls is Some(true) {
    attrs.set("controls", "true")
  }
  if autoplay is Some(true) {
    attrs.set("autoplay", "true")
  }
  if loop_enabled is Some(true) {
    attrs.set("loop", "true")
  }
  if muted is Some(true) {
    attrs.set("muted", "true")
  }
  if on_play is Some(on_play) {
    event.set("play", on_play)
  }
  if on_pause is Some(on_pause) {
    event.set("pause", on_pause)
  }
  Element({ name: "audio", attrs, event, style, children })
}
