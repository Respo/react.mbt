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
/// Options for React 19.2 Web Streams server rendering.
struct StreamRenderOptions {
  js_value : @dom.JsObscure
}

///|
extern "js" fn react_stream_render_options(
  identifier_prefix : @dom.JsObscure,
  bootstrap_scripts : FixedArray[String],
  bootstrap_modules : FixedArray[String],
  nonce : @dom.JsObscure,
  on_error : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (identifierPrefix, bootstrapScripts, bootstrapModules, nonce, onError) => {
  #|   const options = {};
  #|   if (identifierPrefix != null) options.identifierPrefix = identifierPrefix;
  #|   if (bootstrapScripts.length > 0) options.bootstrapScripts = bootstrapScripts;
  #|   if (bootstrapModules.length > 0) options.bootstrapModules = bootstrapModules;
  #|   if (nonce != null) options.nonce = nonce;
  #|   if (onError != null) {
  #|     options.onError = (error) => {
  #|       onError(error);
  #|       return undefined;
  #|     };
  #|   }
  #|   return options;
  #| }

///|
/// Creates options for `render_to_readable_stream`.
/// `identifier_prefix` must match the client `RootOptions` during hydration.
pub fn StreamRenderOptions::new(
  identifier_prefix? : String,
  bootstrap_scripts? : Array[String] = [],
  bootstrap_modules? : Array[String] = [],
  nonce? : String,
  on_error? : (ReactError) -> Unit,
) -> StreamRenderOptions {
  let prefix = match identifier_prefix {
    Some(value) => @dom.JsObscure::from_string(value)
    None => @dom.JsObscure::null()
  }
  let js_nonce = match nonce {
    Some(value) => @dom.JsObscure::from_string(value)
    None => @dom.JsObscure::null()
  }
  let js_on_error = match on_error {
    Some(callback) => @dom.v_to_js_obscure(callback)
    None => @dom.JsObscure::null()
  }
  StreamRenderOptions::{
    js_value: react_stream_render_options(
      prefix,
      FixedArray::from_array(bootstrap_scripts),
      FixedArray::from_array(bootstrap_modules),
      js_nonce,
      js_on_error,
    ),
  }
}

///|
/// A React 19.2 server-rendered Web Stream and its abort controller.
/// Reading the stream transfers its one-shot body ownership to the consumer.
struct ReactReadableStream {
  js_value : @dom.JsObscure
}

///|
extern "js" fn react_render_to_readable_stream(
  vdom : @dom.JsObscure,
  options : @dom.JsObscure,
) -> @js_async.Promise[@dom.JsObscure] =
  #| async (vdom, options) => {
  #|   const controller = new AbortController();
  #|   const stream = await globalThis.ReactDOMServer.renderToReadableStream(
  #|     vdom,
  #|     { ...(options ?? {}), signal: controller.signal },
  #|   );
  #|   return { stream, controller };
  #| }

///|
extern "js" fn react_readable_stream_all_ready(
  handle : @dom.JsObscure,
) -> @js_async.Promise[Unit] =
  #| (handle) => handle.stream.allReady.then(() => undefined)

///|
extern "js" fn react_readable_stream_text(
  handle : @dom.JsObscure,
) -> @js_async.Promise[String] =
  #| (handle) => new Response(handle.stream).text()

///|
extern "js" fn react_readable_stream_abort(
  handle : @dom.JsObscure,
  reason : @dom.JsObscure,
) -> Unit =
  #| (handle, reason) => handle.controller.abort(reason ?? undefined)

///|
extern "js" fn react_readable_stream_value(
  handle : @dom.JsObscure,
) -> @js_async.JsReadableStream =
  #| (handle) => handle.stream

///|
/// Starts React 19.2 Web Streams rendering and resolves as soon as the shell is
/// ready. A shell failure rejects this async call.
pub async fn render_to_readable_stream(
  vdom : VirtualNode,
  options? : StreamRenderOptions,
) -> ReactReadableStream {
  let js_options = match options {
    Some(value) => value.js_value
    None => @dom.JsObscure::null()
  }
  let handle = react_render_to_readable_stream(vdom.to_js_obscure(), js_options).wait()
  ReactReadableStream::{ js_value: handle }
}

///|
/// Waits until the shell and every suspended boundary are ready. Use this for
/// crawlers or static generation when progressive delivery is unnecessary.
pub async fn ReactReadableStream::wait_all_ready(
  self : ReactReadableStream,
) -> Unit {
  react_readable_stream_all_ready(self.js_value).wait()
}

///|
/// Consumes the entire stream as UTF-8 HTML. A stream body can be consumed only
/// once; use `to_js_readable_stream` for direct Web API integration instead.
pub async fn ReactReadableStream::read_text(
  self : ReactReadableStream,
) -> String {
  react_readable_stream_text(self.js_value).wait()
}

///|
/// Aborts pending server work. React emits the nearest Suspense fallbacks and
/// leaves unfinished content for the client to render.
pub fn ReactReadableStream::abort(
  self : ReactReadableStream,
  reason? : String,
) -> Unit {
  let js_reason = match reason {
    Some(value) => @dom.JsObscure::from_string(value)
    None => @dom.JsObscure::null()
  }
  react_readable_stream_abort(self.js_value, js_reason)
}

///|
/// Returns the underlying one-shot Web `ReadableStream` for a Response or other
/// JavaScript server-runtime integration.
pub fn ReactReadableStream::to_js_readable_stream(
  self : ReactReadableStream,
) -> @js_async.JsReadableStream {
  react_readable_stream_value(self.js_value)
}

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
