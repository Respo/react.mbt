# tiye/react

> React bindings for MoonBit

## Project Status

**🚧 This is an early project**

This is an experimental hobby project exploring MoonBit bindings for React. The API is unstable and may change frequently. Not recommended for production use. This project is intended for technical exploration and learning purposes only.

## API Stability and JavaScript Boundary

All public APIs are experimental. The virtual-node, element-helper, and basic
hook APIs are the maintained baseline; React 19 concurrent hooks and the broad
event catalogue are newer additions that should receive application-level
testing before adoption. Deprecated compatibility APIs remain available only
until the next breaking release.

`JsObscure` is the explicit escape hatch at the MoonBit/JavaScript boundary.
Use it for hook dependency values with `obscure(value)` and for intentional JS
interoperation only. Generic hook and component values cross React using the
MoonBit JavaScript representation, so they must be values that the generated
MoonBit runtime can pass directly; do not assume JSON serialization or deep
cloning occurs.

The browser entry point must initialize `globalThis.React`,
`globalThis.ReactDOM`, and `globalThis.ReactDOMClient` before calling this
package. (`window` and `globalThis` are the same global object in a browser.)
`ReactDOM` supplies DOM-specific Hooks such as `use_form_status`; the bundled
demo shows the supported ESM integration pattern.

Component functions must be placed in the virtual DOM through `component`, not
called directly. Use `component_with_children` when the component needs to
place caller-supplied children in its own tree.

Apply `with_key` to children in dynamic collections, using stable application
identities rather than array indexes.

## Bound APIs and Types

### Core Rendering API

- `render(vdom: VirtualNode, parent: @dom.Element) -> Unit` - Render virtual DOM to specified parent element
- `render_with_options(vdom: VirtualNode, parent: @dom.Element, options: RootOptions) -> Unit` - Create and render through a configured React root
- `hydrate_root(vdom: VirtualNode, parent: @dom.Element, options?: RootOptions) -> Unit` - Attach React to matching server-rendered HTML
- `unmount(parent: @dom.Element) -> Unit` - Unmount the React root for an element
- `create_portal(child: VirtualNode, parent: @dom.Element, key?: String) -> VirtualNode` - Place DOM in another container while retaining React-tree context and event propagation
- `render_to_string(vdom: VirtualNode, identifier_prefix?: String) -> String` - Basic synchronous SSR/SSG renderer
- `RootOptions::new(...) -> RootOptions` - Configure `identifierPrefix` and caught, uncaught, and recoverable error callbacks
- `ReactError::message() -> String`, `ReactErrorInfo::component_stack() -> String` - Inspect root callback values
- `component[T](f: (T) -> VirtualNode, props: T, children: Array[VirtualNode]) -> VirtualNode` - Create a leaf component
- `component_with_children[T](f: (T, Array[VirtualNode]) -> VirtualNode, props: T, children: Array[VirtualNode]) -> VirtualNode` - Create a component that places its children
- `define_component[T](render: (T) -> VirtualNode) -> ReactComponent[T]` - Define a stable reusable component type with typed MoonBit props
- `ReactComponent::render(props: T) -> VirtualNode` - Render a reusable typed component
- `ReactComponent::memo(are_props_equal?: (T, T) -> Bool) -> ReactComponent[T]` - Memoize a typed component with default identity or a typed comparator
- `lazy_component[T](loader: async () -> ReactComponent[T]) -> ReactComponent[T]` - Lazily load and cache a typed component through Suspense
- `suspense(fallback: VirtualNode, children: Array[VirtualNode]) -> VirtualNode` - Display fallback UI until suspended children are ready
- `component_from_js[T](component: JsObscure) -> ReactComponent[T]` - Declare the typed MoonBit props contract for a trusted JavaScript component
- `VirtualNode::with_key(key: String) -> VirtualNode` - Assign a stable React reconciliation key without adding a DOM wrapper
- `create_context[T](default_value: T) -> ReactContext[T]` - Create a typed React Context
- `ReactContext::provider(value: T, children: Array[VirtualNode]) -> VirtualNode` - Provide a value without adding a DOM wrapper

For example, use `component(my_component, props, [])`, never
`my_component(props)` directly in a virtual DOM tree.

### Hooks API

- `use_state[T](initial: T) -> (T, (T) -> Unit)` - State management hook
- `use_context[T](context: ReactContext[T]) -> T` - Read and subscribe to the nearest typed Context provider
- `use_state_with_updater[T](initial: T) -> (T, (StateUpdate[T]) -> Unit)` - State hook with direct and functional updates
- `use_reducer_with_initial[S, A](initial: S, reducer: (S, A) -> S) -> (S, (A) -> Unit)` - Reducer hook for any explicit state type
- `use_reducer[S: Default, A](initial?: S, reducer: (S, A) -> S) -> (S, (A) -> Unit)` - Reducer hook
- `use_effect_once(effect: () -> Unit) -> Unit` - Effect hook that runs only once
- `use_effect_cleanup_deps(effect: () -> () -> Unit, deps: Array[JsObscure]) -> Unit` - Effect hook with a cleanup function
- `use_effect_once_with_cleanup(effect: () -> () -> Unit) -> Unit` - One-time effect with a cleanup function
- `use_effect_deps(effect: () -> Unit, deps: Array[JsObscure]) -> Unit` - Effect hook with dependencies
- `use_layout_effect_deps(effect: () -> Unit, deps: Array[JsObscure]) -> Unit` - Layout effect hook
- `use_memo_deps[A](factory: () -> A, deps: Array[JsObscure]) -> A` - Memoization hook
- `use_callback_deps[F](callback: F, deps: Array[JsObscure]) -> F` - Callback memoization hook
- `use_effect_event[F](callback: F) -> F` - React 19.2 effect-only callback that reads latest state without re-subscribing an effect
- `use_action_state[S, A](initial: S, action: (S, A) -> S) -> (S, (A) -> Unit, Bool)` - React 19 action state, dispatch, and pending flag
- `use_async_action_state[S, A](initial: S, action: async (S, A) -> S) -> (S, (A) -> Unit, Bool)` - Export a MoonBit async reducer as a Promise-returning React Action
- `use_optimistic[S, A](value: S, reducer: (S, A) -> S) -> (S, (A) -> Unit)` - Temporary optimistic state scoped to a React Action
- `use_form_status() -> FormStatus` - Read pending data, method, and action from the nearest parent form
- `use_callback0_deps(f: () -> Unit, deps: Array[JsObscure]) -> () -> Unit` - Zero-argument callback hook
- `use_ref[T](initial: T) -> ReactRef[T]` - Reference hook
- `use_dom_ref() -> ReactDomRef` - Nullable DOM-element ref hook whose `current()` value is `None` before mount and after unmount
- `use_id() -> String` - Stable component-local identifier hook
- `use_deferred_value[T](value: T) -> T` - Deferred-value hook for non-urgent rendering
- `use_transition() -> (Bool, (() -> Unit) -> Unit)` - Transition state and starter hook
- `start_transition(action: () -> Unit) -> Unit` - Start a transition when pending state is not needed
- `use_sync_external_store[T](subscribe, get_snapshot, get_server_snapshot?) -> T` - Read and subscribe to a typed immutable external-store snapshot
- `use_imperative_ref[T]() -> ImperativeRef[T]` - Create a nullable typed ref for a custom component handle
- `use_imperative_handle_deps[T](ref: ImperativeRef[T], create_handle: () -> T, deps: Array[JsObscure]) -> Unit` - Expose a typed React 19 imperative handle
- `obscure[T](v: T) -> JsObscure` - Dependency conversion helper function

### HTML Element Bindings

- `div`, `span`, `p`, `h1`, `h2`, `h3` - Basic text elements
- `form`, `button`, `input`, `textarea`, `select`, `option` - Form elements
- `a`, `img`, `video`, `audio` - Media and link elements
- `ul`, `ol`, `li` - List elements
- `section`, `article`, `header`, `footer`, `nav`, `aside` - Semantic elements
- `label` - Label element
- Generated table helpers: `table`, `caption`, `colgroup`, `col`, `thead`,
  `tbody`, `tfoot`, `tr`, `th`, and `td`
- Generated form and interactive helpers: `fieldset`, `legend`, `datalist`,
  `optgroup`, `output`, `progress`, `meter`, `dialog`, `details`, and `summary`
- Generated React 19 metadata helpers: `title`, `meta`, `link`, `style_tag`, and
  `script_tag`
- Generated core SVG helpers include `svg`, `g`, `defs`, `symbol`, `path`,
  `circle`, `ellipse`, `rect`, `line`, gradients, clipping/masking, text, and
  `use_`

The generated set contains 54 helpers across six categories. Every generated
helper includes typed common `role`, `title`, `tab_index`, `hidden`,
`aria_label`, and `data_testid` props plus the applicable tag-specific props.
SVG and metadata names use React camel case at the JavaScript boundary, such as
`viewBox`, `strokeWidth`, `httpEquiv`, and `xlinkHref`.

### Event Handling

`DOMEventType` covers clipboard, composition, keyboard, mouse, pointer, wheel,
form, drag, touch, media, animation, and transition events. It maps each value
to React's camel-cased `onXxx` property automatically.

- `DOMEvent` type and its methods:
  - `target_value() -> String` - Get form element value
  - `target_checked() -> Bool` - Get checkbox or radio checked state
  - `key() -> String`, `key_code() -> Int` - Keyboard events
  - `client_x() -> Int`, `client_y() -> Int` - Mouse coordinates
  - `prevent_default()`, `stop_propagation()` - Event control
  - `ctrl_key()`, `shift_key()`, `alt_key()`, `meta_key() -> Bool` - Modifier key detection

### Styles and Attributes

- `ElementAttrs` - HTML attribute management, including typed string, boolean, integer, floating-point, and JavaScript-value setters
- `ElementEvents` - Event handler management
- `RespoStyle` - CSS styles (from `@css` module)
- `InputType` enum - Support for all HTML input types
- `StateUpdate[T]` - `Set(value)` or `Update(fn(previous) { ... })` for safely deriving state from the latest React value

`innerHTML` parameters are converted to React's `dangerouslySetInnerHTML` API.
Only pass trusted, sanitized HTML through this escape hatch. Combining
`innerHTML` with children is rejected before the element reaches React.

Use `ElementAttrs::set` for string attributes, `set_bool` for React boolean
properties such as `disabled`, `set_int` for integral properties such as
`rows`, and `set_float` for fractional numeric properties such as progress and
meter values. The built-in element helpers use these typed conversions
automatically.
Use `set_js_value` only for explicit React values such as a DOM ref:
`attrs.set_js_value("ref", input_ref.to_js_obscure())`.
For controlled checkbox or radio inputs, use `input(checked=value)` so both
`true` and `false` reach React as booleans.
Use `default_value` and `default_checked` for uncontrolled form elements;
combining them with `value` or `checked` is rejected. For DOM elements, prefer
`use_dom_ref()` and attach its JavaScript ref object through `set_js_value`.
`ReactDomRef::current()` returns `Some(element)` only while the element is
mounted.
Controlled fields require `on_change`, or an explicit `read_only=true` or
`disabled=true` state. A `multiple=true` select uses the `values` or
`default_values` array parameters; individual options do not accept
`selected`.

React 19 function Actions use the typed `FormAction` wrapper. Wrap the
`ReactFormData` dispatcher returned by `use_action_state` or
`use_async_action_state` with `form_action(dispatch)`, or convert a direct
MoonBit async form function with `async_form_action`. Pass the result through
`form(action=...)`, `button(form_action=...)`, or a submit/image
`input(form_action=...)`. `use_form_status` must run in a child component below
the form it observes. The async bridge is pinned to `moonbitlang/async@0.20.3`,
the newest release compatible with this repository's pinned MoonBit compiler.

`declare_contained_style` is deprecated; use `contained_static_style` instead.
`ReactRef::from` is deprecated because its constructor-like name hides a Hook
call; use `use_ref` or `use_dom_ref` at the top level of a component.

Static-style declarations are safe during server-side rendering or pre-rendering:
without a browser document they return their deterministic class name without
injecting a tag. The browser's module evaluation then performs the injection.

### Portals, Roots, and SSR Scope

`create_portal` changes physical DOM placement only: context and events still
follow the owning React tree. `render_with_options` applies its options only
when it creates a root; later calls for the same parent reuse that root.

The supported SSR/SSG path is deliberately narrow and explicit:

- `render_to_string` is a synchronous `react-dom/server` binding.
- `hydrate_root` requires markup identical to the initial client tree.
- `identifier_prefix` must be identical in `render_to_string` and
  `RootOptions::new` when the tree uses `use_id`.
- Streaming, waiting for suspended data, async server rendering, React Server
  Components, and framework routing/data protocols are not provided.

For a server or build entry, initialize only the renderer globals it needs:

```js
import * as React from "react";
import * as ReactDOMServer from "react-dom/server";

globalThis.React = React;
globalThis.ReactDOMServer = ReactDOMServer;
```

Then initialize `React`, `ReactDOM`, and `ReactDOMClient` in the browser entry
before calling `hydrate_root`. Do not bundle `react-dom/server` into ordinary
client code merely to hydrate markup that was already generated on the server.

### External Stores and Component Integration

`use_sync_external_store` follows React's immutable snapshot contract. Keep the
`subscribe` function stable across renders, return an unsubscribe callback, and
return the same snapshot value while the store has not changed. When rendering
on the server, provide `get_server_snapshot` and return the same initial value
during hydration.

`ReactComponent[T]` carries a single typed MoonBit props value. A component
created through `component_from_js` receives that value as
`props.moonbitProps`; this explicit carrier avoids spreading or depending on
MoonBit's generated JavaScript object representation. `memo` compares this
single value with `Object.is` by default, or receives previous and next typed
values in its custom comparator.

Declare memoized and lazy components outside ordinary render paths. A
`lazy_component` loader resolves to `ReactComponent[T]`; React caches both the
loader Promise and its resolved component. Render it below `suspense` so a
fallback is visible while loading.

React 19 makes refs available as component props, so this binding intentionally
does not add a new `forwardRef` wrapper. Pass `ImperativeRef[T]` through typed
props and call `use_imperative_handle_deps` in the child. `current()` returns
`None` before commit and after cleanup. Prefer declarative props whenever the
behavior does not genuinely require an imperative handle.

### Virtual DOM Types

- `VirtualNode` - Base virtual node type
- `VirtualElement` - Virtual element type
- `Text(String)` - Text node

## Quick Start

Before writing any MoonBit code, make sure to include the React bindings in your project.

```js
import * as React from "react";
import * as ReactDOM from "react-dom";
import * as ReactDOMClient from "react-dom/client";

globalThis.React = React;
globalThis.ReactDOM = ReactDOM;
globalThis.ReactDOMClient = ReactDOMClient;
```

Here's a simple example of how to use this library:

```moonbit
// Define your component props
struct ContainerProps {} derive(Default)

// Create a functional component
fn comp_container(_v : ContainerProps) -> @react.VirtualNode {
  let (counter, set_counter) = @react.use_state(Float::from_double(0.0))

  @react.div(
    id="container",
    style=@css.respo_style(
      color=@css.CssColor::Blue,
      font_family="Arial",
      padding=@css.CssSize::Px(10.0),
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
  let props : ContainerProps = Default::default()

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

## Development

The package follows the current MoonBit manifest format (`moon.mod` and
`moon.pkg`). To run the checks locally:

```sh
moon check
moon test
moon info
corepack yarn install --frozen-lockfile
corepack yarn generate:dom
corepack yarn check:generated
corepack yarn build
corepack yarn test:browser
```

CI pins MoonBit compiler `0.10.4+2cc641edf` and validates Node 22 with Yarn
1.22.22. `test:browser` runs deterministic TodoMVC and React runtime conformance
flows in Chromium, including StrictMode lifecycle, batching, root reuse, DOM
ref cleanup, async form Actions, form status, optimistic rollback, portals,
root error callbacks, synchronous server rendering, hydration, external-store
subscription lifecycles, memo/lazy/Suspense, typed JavaScript interoperation,
imperative handles, and generated HTML/SVG/metadata DOM behavior; install it
once locally with `yarn playwright install chromium`.
Update the toolchain pin only through the full check, unit-test, interface,
browser-test, and browser-build matrix. This revision was verified with MoonBit
`0.1.20260713`, React 19.2.8, and Vite 8.2.x.

The browser entry point loads React, ReactDOM, ReactDOMClient, and the demo-only
server renderer before the generated MoonBit application. `render` can be
called again for the same parent element; the binding reuses its React root
rather than creating a second one.

## Release

Prepare releases on a branch by aligning `moon.mod`, `package.json`, the dated
Changelog section, and bilingual `release-notes/vX.Y.Z.md`. Run
`yarn check:release`; it requires exact version agreement, complete historical
tag coverage, an empty `Unreleased` section, and an exact 17-file package
allowlist.

After the preparation PR is merged, create an annotated `vX.Y.Z` tag on
`main`, then create and publish a GitHub Release whose title exactly matches
that tag. The `release.published` event triggers **Publish release**. It verifies
tag identity and main ancestry, generated sources, MoonBit
check/test/interface/format results, real Chromium conformance, the browser
build, and the package allowlist before uploading the archive and
`SHA256SUMS` to the Release.

The same workflow publishes to mooncakes.io using the repository or inherited
organization Secret `MOON_CREDENTIALS`; registry credentials never leave the
ephemeral Actions runner. It then resolves `tiye/react@X.Y.Z` from a fresh
temporary consumer, compiles a generated-DOM smoke use, runs JS check/build,
and preserves the exact logs as an Actions artifact. A release is not complete
until this downstream check passes.

Use the workflow's `workflow_dispatch` input only to recover or verify an
already-published GitHub Release, such as one created before the workflow was
installed. The separate **Verify published package** workflow remains
available for registry-only rechecks.

### License

Apache 2.0
