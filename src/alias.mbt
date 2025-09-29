///|
/// Creates a `span` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `span` element.
///
/// Example:
///
/// ```moonbit
/// let _ = span(
///   class_name="text-bold",
///   on_click=fn(_e) { println("Clicked!") }, []
/// )
/// ```
///
pub fn span(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the span element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates a `p` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `p` element.
///
pub fn p(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the p element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `h1` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `h1` element.
///
pub fn h1(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the h1 element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `h2` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `h2` element.
///
pub fn h2(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the h2 element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `h3` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `h3` element.
///
pub fn h3(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the h3 element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `h4` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `h4` element.
///
pub fn h4(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the h4 element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `h5` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `h5` element.
///
pub fn h5(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the h5 element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `h6` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `h6` element.
///
pub fn h6(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the h6 element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `a` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `a` element.
///
pub fn a(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the a element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// The URL that the hyperlink points to.
  href? : String,
  /// Where to display the linked URL (e.g., "_blank", "_self").
  target? : String,
  /// Click event handler.
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
/// Creates an `input` element with the specified attributes, event handlers, and
/// properties.
///
/// Returns a virtual DOM node representing an `input` element.
///
pub fn input(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// The type of input (e.g., "text", "password", "email").
  input_type? : String,
  /// The current value of the input.
  value? : String,
  /// Placeholder text displayed when input is empty.
  placeholder? : String,
  /// Whether the input is disabled.
  disabled? : Bool,
  /// Click event handler.
  on_click? : (DOMEvent) -> Unit,
  /// Change event handler (fired when value changes and input loses focus).
  on_change? : (DOMEvent) -> Unit,
  /// Input event handler (fired on every keystroke).
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
/// Creates a `button` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `button` element.
///
pub fn button(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the button element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// The type of button (e.g., "button", "submit", "reset").
  button_type? : String,
  /// Whether the button is disabled.
  disabled? : Bool,
  /// Click event handler.
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
/// Creates a `textarea` element with the specified attributes, event handlers, and
/// properties.
///
/// Returns a virtual DOM node representing a `textarea` element.
///
pub fn textarea(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// The current value of the textarea.
  value? : String,
  /// Placeholder text displayed when textarea is empty.
  placeholder? : String,
  /// Number of visible text lines.
  rows? : Int,
  /// Number of visible character columns.
  cols? : Int,
  /// Whether the textarea is disabled.
  disabled? : Bool,
  /// Change event handler (fired when value changes and textarea loses focus).
  on_change? : (DOMEvent) -> Unit,
  /// Input event handler (fired on every keystroke).
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
/// Creates a `select` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `select` element.
///
pub fn select(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes (option elements) of the select element.
  children : Array[VirtualNode],
  /// The currently selected value.
  value? : String,
  /// Whether the select is disabled.
  disabled? : Bool,
  /// Whether multiple options can be selected.
  multiple? : Bool,
  /// Change event handler (fired when selection changes).
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
/// Creates an `option` element with the specified attributes and properties.
///
/// Returns a virtual DOM node representing an `option` element.
///
pub fn option(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the option element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// The value of the option when selected.
  value? : String,
  /// Whether the option is selected by default.
  selected? : Bool,
  /// Whether the option is disabled.
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
/// Creates a `section` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `section` element.
///
pub fn section(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the section element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `article` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `article` element.
///
pub fn article(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the article element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates a `header` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `header` element.
///
pub fn header(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the header element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates a `footer` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `footer` element.
///
pub fn footer(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the footer element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates a `nav` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `nav` element.
///
pub fn nav(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the nav element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `aside` element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `aside` element.
///
pub fn aside(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the aside element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates a `ul` (unordered list) element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `ul` element.
///
pub fn ul(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the ul element (typically li elements).
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `ol` (ordered list) element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing an `ol` element.
///
pub fn ol(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the ol element (typically li elements).
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates a `li` (list item) element with the specified attributes, event handlers, and
/// children.
///
/// Returns a virtual DOM node representing a `li` element.
///
pub fn li(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the li element.
  children : Array[VirtualNode],
  /// Raw HTML content to be inserted inside the element.
  innerHTML? : String,
  /// Click event handler.
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
/// Creates an `img` element with the specified attributes, event handlers, and
/// image properties.
///
/// Returns a virtual DOM node representing an `img` element.
///
pub fn img(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Image source URL.
  src? : String,
  /// Alternative text for the image.
  alt? : String,
  /// Image width.
  width? : String,
  /// Image height.
  height? : String,
  /// Click event handler.
  on_click? : (DOMEvent) -> Unit,
  /// Load event handler (fired when image loads successfully).
  on_load? : (DOMEvent) -> Unit,
  /// Error event handler (fired when image fails to load).
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
/// Creates a `video` element with the specified attributes, event handlers, and
/// video properties.
///
/// Returns a virtual DOM node representing a `video` element.
///
pub fn video(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the video element (e.g., source elements).
  children : Array[VirtualNode],
  /// Video source URL.
  src? : String,
  /// Whether to show video controls.
  controls? : Bool,
  /// Whether to autoplay the video.
  autoplay? : Bool,
  /// Whether to loop the video.
  loop_enabled? : Bool,
  /// Whether the video is muted.
  muted? : Bool,
  /// Video width.
  width? : String,
  /// Video height.
  height? : String,
  /// Click event handler.
  on_click? : (DOMEvent) -> Unit,
  /// Play event handler (fired when video starts playing).
  on_play? : (DOMEvent) -> Unit,
  /// Pause event handler (fired when video is paused).
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
/// Creates an `audio` element with the specified attributes, event handlers, and
/// audio properties.
///
/// Returns a virtual DOM node representing an `audio` element.
///
pub fn audio(
  /// HTML element ID.
  id? : String,
  /// Base CSS class name.
  class_name? : String,
  /// Additional CSS class names to be appended to the base class.
  class_list? : Array[String] = [],
  /// Additional HTML attributes.
  attrs? : ElementAttrs,
  /// Event handlers map.
  event? : ElementEvents,
  /// CSS styles.
  style? : RespoStyle = respo_style(),
  /// Child nodes of the audio element (e.g., source elements).
  children : Array[VirtualNode],
  /// Audio source URL.
  src? : String,
  /// Whether to show audio controls.
  controls? : Bool,
  /// Whether to autoplay the audio.
  autoplay? : Bool,
  /// Whether to loop the audio.
  loop_enabled? : Bool,
  /// Whether the audio is muted.
  muted? : Bool,
  /// Play event handler (fired when audio starts playing).
  on_play? : (DOMEvent) -> Unit,
  /// Pause event handler (fired when audio is paused).
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
