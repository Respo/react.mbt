///|
/// The JavaScript error passed to a React root error callback.
#external
pub type ReactError

///|
/// Metadata passed to a React root error callback.
#external
pub type ReactErrorInfo

///|
/// Returns the JavaScript Error message reported by React.
pub extern "js" fn ReactError::message(self : ReactError) -> String =
  #| (error) => error?.message ?? String(error)

///|
/// Returns the React component stack associated with a root error.
pub extern "js" fn ReactErrorInfo::component_stack(
  self : ReactErrorInfo,
) -> String =
  #| (info) => info?.componentStack ?? ""

///|
/// Configuration shared by `createRoot` and `hydrateRoot`.
struct RootOptions {
  js_value : @dom.JsObjectObscure
}

///|
/// Creates root options matching React 19's root error and identifier options.
/// `identifier_prefix` must match the server renderer during hydration.
pub fn RootOptions::new(
  identifier_prefix? : String,
  on_caught_error? : (ReactError, ReactErrorInfo) -> Unit,
  on_uncaught_error? : (ReactError, ReactErrorInfo) -> Unit,
  on_recoverable_error? : (ReactError, ReactErrorInfo) -> Unit,
) -> RootOptions {
  let options = @dom.JsObjectObscure::new()
  match identifier_prefix {
    Some(prefix) =>
      options.set("identifierPrefix", @dom.JsObscure::from_string(prefix))
    None => ()
  }
  match on_caught_error {
    Some(callback) =>
      options.set("onCaughtError", @dom.v_to_js_obscure(callback))
    None => ()
  }
  match on_uncaught_error {
    Some(callback) =>
      options.set("onUncaughtError", @dom.v_to_js_obscure(callback))
    None => ()
  }
  match on_recoverable_error {
    Some(callback) =>
      options.set("onRecoverableError", @dom.v_to_js_obscure(callback))
    None => ()
  }
  RootOptions::{ js_value: options }
}

///|
fn RootOptions::to_js_obscure(self : RootOptions) -> @dom.JsObscure {
  self.js_value.to_js_obscure()
}

///|
extern "js" fn react_render(
  vdom : @dom.JsObscure,
  parent : @dom.Node,
  options : @dom.JsObscure,
) -> Unit =
  #| (vdom, parent, options) => {
  #|   const roots = globalThis.__moonbitReactRoots ??= new WeakMap();
  #|   let root = roots.get(parent);
  #|   if (!root) {
  #|     root = globalThis.ReactDOMClient.createRoot(parent, options ?? undefined);
  #|     roots.set(parent, root);
  #|   }
  #|   root.render(vdom);
  #| }

///|
extern "js" fn react_hydrate_root(
  vdom : @dom.JsObscure,
  parent : @dom.Node,
  options : @dom.JsObscure,
) -> Unit =
  #| (vdom, parent, options) => {
  #|   const roots = globalThis.__moonbitReactRoots ??= new WeakMap();
  #|   if (roots.has(parent)) {
  #|     throw new Error("hydrate_root requires a parent without an existing React root");
  #|   }
  #|   const root = globalThis.ReactDOMClient.hydrateRoot(
  #|     parent,
  #|     vdom,
  #|     options ?? undefined,
  #|   );
  #|   roots.set(parent, root);
  #| }

///|
extern "js" fn react_unmount(parent : @dom.Node) -> Unit =
  #| (parent) => {
  #|   const roots = globalThis.__moonbitReactRoots;
  #|   const root = roots?.get(parent);
  #|   if (root) {
  #|     root.unmount();
  #|     roots.delete(parent);
  #|   }
  #| }

///|
extern "js" fn react_create_portal(
  child : @dom.JsObscure,
  parent : @dom.Node,
  key : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (child, parent, key) => key == null
  #|   ? globalThis.ReactDOM.createPortal(child, parent)
  #|   : globalThis.ReactDOM.createPortal(child, parent, key)

///|
extern "js" fn react_render_to_string(
  vdom : @dom.JsObscure,
  identifier_prefix : @dom.JsObscure,
) -> String =
  #| (vdom, identifierPrefix) => globalThis.ReactDOMServer.renderToString(
  #|   vdom,
  #|   identifierPrefix == null ? undefined : { identifierPrefix },
  #| )

///|
/// Renders a virtual DOM node to the specified parent element. Repeated calls
/// for the same parent reuse its React root.
pub fn render(vdom : VirtualNode, parent : @dom.Element) -> Unit {
  react_render(
    vdom.to_js_obscure(),
    parent.reinterpret_as_node(),
    @dom.JsObscure::null(),
  )
}

///|
/// Renders through a new root configured with React 19 root options. Options
/// are consumed only when this call creates the root; later renders reuse it.
pub fn render_with_options(
  vdom : VirtualNode,
  parent : @dom.Element,
  options : RootOptions,
) -> Unit {
  react_render(
    vdom.to_js_obscure(),
    parent.reinterpret_as_node(),
    options.to_js_obscure(),
  )
}

///|
/// Hydrates React-generated HTML already present in `parent`. The initial VDOM
/// must produce identical markup. Later `render` calls reuse the hydrated root.
pub fn hydrate_root(
  vdom : VirtualNode,
  parent : @dom.Element,
  options? : RootOptions,
) -> Unit {
  let js_options = match options {
    Some(value) => value.to_js_obscure()
    None => @dom.JsObscure::null()
  }
  react_hydrate_root(
    vdom.to_js_obscure(),
    parent.reinterpret_as_node(),
    js_options,
  )
}

///|
/// Creates a React portal whose DOM is placed in `parent` while context and
/// event propagation continue to follow the owning React tree.
pub fn create_portal(
  child : VirtualNode,
  parent : @dom.Element,
  key? : String,
) -> VirtualNode {
  let js_key = match key {
    Some(value) => @dom.JsObscure::from_string(value)
    None => @dom.JsObscure::null()
  }
  JsNode(
    react_create_portal(
      child.to_js_obscure(),
      parent.reinterpret_as_node(),
      js_key,
    ),
  )
}

///|
/// Renders a React tree to an HTML string for basic synchronous SSR or SSG.
/// This intentionally does not provide streaming or wait for suspended data.
pub fn render_to_string(
  vdom : VirtualNode,
  identifier_prefix? : String,
) -> String {
  let js_prefix = match identifier_prefix {
    Some(value) => @dom.JsObscure::from_string(value)
    None => @dom.JsObscure::null()
  }
  react_render_to_string(vdom.to_js_obscure(), js_prefix)
}

///|
/// Unmounts the React root associated with a parent element, if one exists.
/// A later call to `render` or `hydrate_root` creates a fresh root.
pub fn unmount(parent : @dom.Element) -> Unit {
  react_unmount(parent.reinterpret_as_node())
}
