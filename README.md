# tiye/react

> React bindings for MoonBit

## Project Status

**🚧 This is an early project**

This is an experimental hobby project exploring MoonBit bindings for React. The API is unstable and may change frequently. Not recommended for production use. This project is intended for technical exploration and learning purposes only.

## Bound APIs and Types

### Core Rendering API

- `render(vdom: VirtualNode, parent: @dom.Element) -> Unit` - Render virtual DOM to specified parent element
- `unmount(parent: @dom.Element) -> Unit` - Unmount the React root for an element
- `component[T](f: (T) -> VirtualNode, props: T, children: Array[VirtualNode]) -> VirtualNode` - Create a leaf component
- `component_with_children[T](f: (T, Array[VirtualNode]) -> VirtualNode, props: T, children: Array[VirtualNode]) -> VirtualNode` - Create a component that places its children

### Hooks API

- `use_state[T](initial: T) -> (T, (T) -> Unit)` - State management hook
- `use_reducer[S: Default, A](initial?: S, reducer: (S, A) -> S) -> (S, (A) -> Unit)` - Reducer hook
- `use_effect_once(effect: () -> Unit) -> Unit` - Effect hook that runs only once
- `use_effect_cleanup_deps(effect: () -> () -> Unit, deps: Array[JsObscure]) -> Unit` - Effect hook with a cleanup function
- `use_effect_once_with_cleanup(effect: () -> () -> Unit) -> Unit` - One-time effect with a cleanup function
- `use_effect_deps(effect: () -> Unit, deps: Array[JsObscure]) -> Unit` - Effect hook with dependencies
- `use_layout_effect_deps(effect: () -> Unit, deps: Array[JsObscure]) -> Unit` - Layout effect hook
- `use_memo_deps[A](factory: () -> A, deps: Array[JsObscure]) -> A` - Memoization hook
- `use_callback_deps[F](callback: F, deps: Array[JsObscure]) -> F` - Callback memoization hook
- `use_callback0_deps(f: () -> Unit, deps: Array[JsObscure]) -> () -> Unit` - Zero-argument callback hook
- `use_ref[T](initial: T) -> ReactRef[T]` - Reference hook
- `use_id() -> String` - Stable component-local identifier hook
- `use_deferred_value[T](value: T) -> T` - Deferred-value hook for non-urgent rendering
- `use_transition() -> (Bool, (() -> Unit) -> Unit)` - Transition state and starter hook
- `start_transition(action: () -> Unit) -> Unit` - Start a transition when pending state is not needed
- `obscure[T](v: T) -> JsObscure` - Dependency conversion helper function

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

- `ElementAttrs` - HTML attribute management, including typed boolean and integer setters
- `ElementEvents` - Event handler management
- `RespoStyle` - CSS styles (from `@css` module)
- `InputType` enum - Support for all HTML input types

`innerHTML` parameters are converted to React's `dangerouslySetInnerHTML` API.
Only pass trusted, sanitized HTML through this escape hatch.

Use `ElementAttrs::set` for string attributes, `set_bool` for React boolean
properties such as `disabled`, and `set_int` for numeric properties such as
`rows`. The built-in element helpers use these typed conversions automatically.
For controlled checkbox or radio inputs, use `input(checked=value)` so both
`true` and `false` reach React as booleans.

`declare_contained_style` is deprecated; use `contained_static_style` instead.

### Virtual DOM Types

- `VirtualNode` - Base virtual node type
- `VirtualElement` - Virtual element type
- `Text(String)` - Text node

## Quick Start

Before writing any MoonBit code, make sure to include the React bindings in your project.

```js
import * as React from "react";
import * as ReactDOMClient from "react-dom/client";

window.React = React;
window.ReactDOMClient = ReactDOMClient;
```

Here's a simple example of how to use this library:

```moonbit
// Define your component props
struct ContainerProps {} derive(Default)

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

This is an early project exploring MoonBit bindings for React. The API is subject to frequent changes and breaking updates. Use at your own risk!

## Development

The package follows the current MoonBit manifest format (`moon.mod` and
`moon.pkg`). To run the checks locally:

```sh
moon check
moon test
moon info
corepack yarn install --frozen-lockfile
corepack yarn build
```

CI pins MoonBit compiler `0.10.4+2cc641edf` and validates Node 22 with Yarn
1.22.22. Update that pin only through the full check, test, interface, and
browser-build matrix. This revision was verified with MoonBit `0.1.20260713`,
React 19.2.x, and Vite 8.2.x.

The browser entry point loads React and ReactDOMClient before the generated
MoonBit application. `render` can be called again for the same parent element;
the binding reuses its React root rather than creating a second one.

## Release

The release workflow verifies the module, builds the demo, packages the MoonBit
module, and attaches the package archive to a GitHub Release. Trigger it by
pushing a tag that exactly matches the module version, for example `v0.1.0`.

To also publish the module to mooncakes.io, log in with `moon login` and run
`moon publish --frozen` after the release checks pass. The registry credential
is deliberately not stored in the GitHub workflow.

### License

Apache 2.0
