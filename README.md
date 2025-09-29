# tiye/preact

> MoonBit bindings for Preact

⚠️ **Early Development Warning**: This library is in a very early stage of development. The API is unstable and may change frequently. This is a hobby project and should not be used in production environments.

## Quick Start

Here's a simple example of how to use this library:

```moonbit
// Define your component props
struct ContainerProps {} derive(Default)

// Implement JsValueTrait for props
impl @preact.JsValueTrait for ContainerProps with to_value(_self) -> @preact.JsValue {
  @preact.JsObject::new().to_value()
}

impl @preact.JsValueTrait for ContainerProps with from_value(
  _value : @preact.JsValue,
) -> ContainerProps {
  ContainerProps::default()
}

// Create a functional component
fn comp_container(_v : ContainerProps) -> @preact.VirtualNode {
  let (counter, set_counter) = @preact.use_state(0.0.to_float())

  @preact.div(
    id="container",
    style=@css.respo_style(
      color=Blue,
      font_family="Arial",
      padding=10.0 |> Px
    ),
    on_click=fn(_) {
      println("clicked \{counter}")
      set_counter(counter + 1.0)
    },
    [
      @preact.Fragment([Text("Demo: ")]),
      Text("Counter \{counter}")
    ],
  )
}

// Render to DOM
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = ContainerProps::default()

  @preact.render(
    @preact.component(comp_container, props, []),
    body,
  )
  println("loaded")
}
```

## Features

- Type-safe virtual DOM construction
- React-style hooks (useState)
- CSS-in-JS styling support
- Event handling
- Component composition

## Project Status

This is an experimental hobby project exploring MoonBit bindings for Preact. The API is subject to frequent changes and breaking updates. Use at your own risk!

### License

Apache 2.0
