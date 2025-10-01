# tiye/react

> MoonBit bindings for React

## Project Status

**⚠️ This project is not actively developed**

This is an experimental hobby project exploring MoonBit bindings for React. The API is unstable and may change frequently. Not recommended for production use. This project is intended for technical exploration and learning purposes only.

## Bound APIs and Types

### Core Rendering API

- `render(vdom: VirtualNode, parent: @dom.Element) -> Unit` - Render virtual DOM to specified parent element
- `component[T: JsValueTrait](f: (T) -> VirtualNode, props: T, children: Array[VirtualNode]) -> VirtualNode` - Create component

### Hooks API

- `use_state[T](initial: T) -> (T, (T) -> Unit)` - State management hook
- `use_reducer[S: Default, A](initial?: S, reducer: (S, A) -> S) -> (S, (A) -> Unit)` - Reducer hook
- `use_effect_once(effect: () -> Unit) -> Unit` - Effect hook that runs only once
- `use_effect_deps(effect: () -> Unit, deps: Array[JsValue]) -> Unit` - Effect hook with dependencies
- `use_layout_effect_deps(effect: () -> Unit, deps: Array[JsValue]) -> Unit` - Layout effect hook
- `use_memo_deps[A](factory: () -> A, deps: Array[JsValue]) -> A` - Memoization hook
- `use_callback_deps[F](callback: F, deps: Array[JsValue]) -> F` - Callback memoization hook
- `use_callback0_deps(f: () -> Unit, deps: Array[JsValue]) -> () -> Unit` - Zero-argument callback hook
- `use_ref[T: JsValueTrait](initial: T) -> ReactRef[T]` - Reference hook
- `obscure[T](v: T) -> JsValue` - Dependency conversion helper function

### HTML Element Bindings

- `div`, `span`, `p`, `h1`, `h2`, `h3` - Basic text elements
- `button`, `input`, `textarea`, `select`, `option` - Form elements
- `a`, `img`, `video`, `audio` - Media and link elements
- `ul`, `ol`, `li` - List elements
- `section`, `article`, `header`, `footer`, `nav`, `aside` - Semantic elements
- `label` - Label element

### Event Handling

- `DOMEvent` type and its methods:
  - `target_value() -> String` - Get form element value
  - `key() -> String`, `key_code() -> Int` - Keyboard events
  - `client_x() -> Int`, `client_y() -> Int` - Mouse coordinates
  - `prevent_default()`, `stop_propagation()` - Event control
  - `ctrl_key()`, `shift_key()`, `alt_key()`, `meta_key() -> Bool` - Modifier key detection

### Styles and Attributes

- `ElementAttrs` - HTML attribute management
- `ElementEvents` - Event handler management
- `RespoStyle` - CSS styles (from `@css` module)
- `InputType` enum - Support for all HTML input types

### Virtual DOM Types

- `VirtualNode` - Base virtual node type
- `VirtualElement` - Virtual element type
- `Text(String)` - Text node

## Quick Start

Here's a simple example of how to use this library:

```moonbit
// Define your component props
struct ContainerProps {} derive(Default)

// Implement JsValueTrait for props
impl @react.JsValueTrait for ContainerProps with to_value(_self) -> @react.JsValue {
  @react.JsObject::new().to_value()
}

impl @react.JsValueTrait for ContainerProps with from_value(
  _value : @react.JsValue,
) -> ContainerProps {
  ContainerProps::default()
}

// Create a functional component
fn comp_container(_v : ContainerProps) -> @react.VirtualNode {
  let (counter, set_counter) = @react.use_state(0.0.to_float())

  @react.div(
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
      @react.Fragment([@react.Text("Demo: ")]),
      @react.Text("Counter \{counter}")
    ],
  )
}

// Render to DOM
fn main {
  let window = @dom.window()
  let doc = window.document()
  let body = doc.body()
  let props = ContainerProps::default()

  @react.render(
    @react.component(comp_container, props, []),
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

This is an experimental hobby project exploring MoonBit bindings for React. The API is subject to frequent changes and breaking updates. Use at your own risk!

### License

Apache 2.0
