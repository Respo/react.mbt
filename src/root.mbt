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
/// Cross-origin policies supported by React DOM resource hints.
/// `Anonymous` omits credentials, while `UseCredentials` includes them.
pub(all) enum ResourceCrossOrigin {
  Anonymous
  UseCredentials
} derive(Eq)

///|
fn ResourceCrossOrigin::to_string(self : ResourceCrossOrigin) -> String {
  match self {
    Anonymous => "anonymous"
    UseCredentials => "use-credentials"
  }
}

///|
/// Browser fetch priorities supported by React DOM resource hints.
/// This is a hint only; the browser retains control over actual scheduling.
pub(all) enum ResourceFetchPriority {
  Auto
  High
  Low
} derive(Eq)

///|
fn ResourceFetchPriority::to_string(self : ResourceFetchPriority) -> String {
  match self {
    Auto => "auto"
    High => "high"
    Low => "low"
  }
}

///|
/// Valid `as` destinations for `preload` according to React 19.2.
/// Select the destination that matches how the browser will consume the URL.
pub(all) enum PreloadDestination {
  Audio
  Document
  Embed
  Fetch
  Font
  Image
  Object
  Script
  Style
  Track
  Video
  Worker
} derive(Eq)

///|
fn PreloadDestination::to_string(self : PreloadDestination) -> String {
  match self {
    Audio => "audio"
    Document => "document"
    Embed => "embed"
    Fetch => "fetch"
    Font => "font"
    Image => "image"
    Object => "object"
    Script => "script"
    Style => "style"
    Track => "track"
    Video => "video"
    Worker => "worker"
  }
}

///|
/// Referrer policies accepted by React 19.2's `preload` options.
pub(all) enum ResourceReferrerPolicy {
  NoReferrerWhenDowngrade
  NoReferrer
  Origin
  OriginWhenCrossOrigin
  UnsafeUrl
} derive(Eq)

///|
fn ResourceReferrerPolicy::to_string(self : ResourceReferrerPolicy) -> String {
  match self {
    NoReferrerWhenDowngrade => "no-referrer-when-downgrade"
    NoReferrer => "no-referrer"
    Origin => "origin"
    OriginWhenCrossOrigin => "origin-when-cross-origin"
    UnsafeUrl => "unsafe-url"
  }
}

///|
/// Stylesheet precedence levels supported by React 19.2 `preinit`.
/// Higher levels are inserted so they can override lower-precedence styles.
pub(all) enum ResourceStylePrecedence {
  Reset
  Low
  Medium
  High
} derive(Eq)

///|
fn ResourceStylePrecedence::to_string(self : ResourceStylePrecedence) -> String {
  match self {
    Reset => "reset"
    Low => "low"
    Medium => "medium"
    High => "high"
  }
}

///|
fn optional_resource_string(value : String?) -> @dom.JsObscure {
  match value {
    Some(text) => @dom.JsObscure::from_string(text)
    None => @dom.JsObscure::null()
  }
}

///|
fn optional_cross_origin(value : ResourceCrossOrigin?) -> @dom.JsObscure {
  match value {
    Some(mode) => @dom.JsObscure::from_string(mode.to_string())
    None => @dom.JsObscure::null()
  }
}

///|
fn optional_fetch_priority(value : ResourceFetchPriority?) -> @dom.JsObscure {
  match value {
    Some(priority) => @dom.JsObscure::from_string(priority.to_string())
    None => @dom.JsObscure::null()
  }
}

///|
/// Typed options for React DOM `preload`.
/// Image-only fields are meaningful only with `PreloadDestination::Image`.
struct PreloadOptions {
  js_value : @dom.JsObscure
}

///|
extern "js" fn react_preload_options(
  destination : String,
  cross_origin : @dom.JsObscure,
  referrer_policy : @dom.JsObscure,
  integrity : @dom.JsObscure,
  mime_type : @dom.JsObscure,
  nonce : @dom.JsObscure,
  fetch_priority : @dom.JsObscure,
  image_src_set : @dom.JsObscure,
  image_sizes : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (as, crossOrigin, referrerPolicy, integrity, type, nonce, fetchPriority, imageSrcSet, imageSizes) => {
  #|   const options = { as };
  #|   if (crossOrigin != null) options.crossOrigin = crossOrigin;
  #|   if (referrerPolicy != null) options.referrerPolicy = referrerPolicy;
  #|   if (integrity != null) options.integrity = integrity;
  #|   if (type != null) options.type = type;
  #|   if (nonce != null) options.nonce = nonce;
  #|   if (fetchPriority != null) options.fetchPriority = fetchPriority;
  #|   if (imageSrcSet != null) options.imageSrcSet = imageSrcSet;
  #|   if (imageSizes != null) options.imageSizes = imageSizes;
  #|   return options;
  #| }

///|
/// Creates options for `preload`.
///
/// `destination` is required by React. `Fetch` resources must also provide a
/// `cross_origin` policy. `image_src_set` and `image_sizes` apply only to
/// `Image`; equivalent image hints are deduplicated by URL, source set, and
/// sizes, while other destinations are deduplicated by URL.
pub fn PreloadOptions::new(
  destination : PreloadDestination,
  cross_origin? : ResourceCrossOrigin,
  referrer_policy? : ResourceReferrerPolicy,
  integrity? : String,
  mime_type? : String,
  nonce? : String,
  fetch_priority? : ResourceFetchPriority,
  image_src_set? : String,
  image_sizes? : String,
) -> PreloadOptions {
  let js_referrer_policy = match referrer_policy {
    Some(policy) => @dom.JsObscure::from_string(policy.to_string())
    None => @dom.JsObscure::null()
  }
  PreloadOptions::{
    js_value: react_preload_options(
      destination.to_string(),
      optional_cross_origin(cross_origin),
      js_referrer_policy,
      optional_resource_string(integrity),
      optional_resource_string(mime_type),
      optional_resource_string(nonce),
      optional_fetch_priority(fetch_priority),
      optional_resource_string(image_src_set),
      optional_resource_string(image_sizes),
    ),
  }
}

///|
/// Shared typed options for ESM module preload and preinit hints.
/// React always receives `as: "script"`; callers configure only CORS and
/// security metadata.
struct ModuleHintOptions {
  js_value : @dom.JsObscure
}

///|
extern "js" fn react_module_hint_options(
  cross_origin : @dom.JsObscure,
  integrity : @dom.JsObscure,
  nonce : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (crossOrigin, integrity, nonce) => {
  #|   const options = { as: "script" };
  #|   if (crossOrigin != null) options.crossOrigin = crossOrigin;
  #|   if (integrity != null) options.integrity = integrity;
  #|   if (nonce != null) options.nonce = nonce;
  #|   return options;
  #| }

///|
/// Creates ESM resource-hint options shared by `preload_module` and
/// `preinit_module`. Repeated calls with the same URL are deduplicated by
/// React, regardless of how many times the wrapper is invoked.
pub fn ModuleHintOptions::new(
  cross_origin? : ResourceCrossOrigin,
  integrity? : String,
  nonce? : String,
) -> ModuleHintOptions {
  ModuleHintOptions::{
    js_value: react_module_hint_options(
      optional_cross_origin(cross_origin),
      optional_resource_string(integrity),
      optional_resource_string(nonce),
    ),
  }
}

///|
/// Typed options for React DOM `preinit` of classic scripts or stylesheets.
/// Use the dedicated constructors so stylesheet precedence cannot be omitted.
struct PreinitOptions {
  js_value : @dom.JsObscure
}

///|
extern "js" fn react_preinit_options(
  resource_type : String,
  precedence : @dom.JsObscure,
  cross_origin : @dom.JsObscure,
  integrity : @dom.JsObscure,
  nonce : @dom.JsObscure,
  fetch_priority : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (as, precedence, crossOrigin, integrity, nonce, fetchPriority) => {
  #|   const options = { as };
  #|   if (precedence != null) options.precedence = precedence;
  #|   if (crossOrigin != null) options.crossOrigin = crossOrigin;
  #|   if (integrity != null) options.integrity = integrity;
  #|   if (nonce != null) options.nonce = nonce;
  #|   if (fetchPriority != null) options.fetchPriority = fetchPriority;
  #|   return options;
  #| }

///|
/// Creates `preinit` options for a classic external script. The resource is
/// fetched and executed when ready; use `preload` when execution should wait.
pub fn PreinitOptions::script(
  cross_origin? : ResourceCrossOrigin,
  integrity? : String,
  nonce? : String,
  fetch_priority? : ResourceFetchPriority,
) -> PreinitOptions {
  PreinitOptions::{
    js_value: react_preinit_options(
      "script",
      @dom.JsObscure::null(),
      optional_cross_origin(cross_origin),
      optional_resource_string(integrity),
      optional_resource_string(nonce),
      optional_fetch_priority(fetch_priority),
    ),
  }
}

///|
/// Creates `preinit` options for a stylesheet. `precedence` is mandatory and
/// determines its order relative to other React-managed stylesheets.
pub fn PreinitOptions::style(
  precedence : ResourceStylePrecedence,
  cross_origin? : ResourceCrossOrigin,
  integrity? : String,
  nonce? : String,
  fetch_priority? : ResourceFetchPriority,
) -> PreinitOptions {
  PreinitOptions::{
    js_value: react_preinit_options(
      "style",
      @dom.JsObscure::from_string(precedence.to_string()),
      optional_cross_origin(cross_origin),
      optional_resource_string(integrity),
      optional_resource_string(nonce),
      optional_fetch_priority(fetch_priority),
    ),
  }
}

///|
extern "js" fn react_flush_sync(callback : () -> Unit) -> Unit =
  #| (callback) => {
  #|   globalThis.ReactDOM.flushSync(() => {
  #|     callback();
  #|   });
  #| }

///|
/// Forces React to apply updates scheduled inside `callback` before returning.
///
/// This is a last-resort escape hatch for third-party or browser integrations
/// that must observe the updated DOM synchronously. It can hurt performance,
/// flush pending work outside the callback, run pending Effects, or reveal
/// Suspense fallbacks. Do not call it during render or an Effect.
pub fn flush_sync(callback : () -> Unit) -> Unit {
  react_flush_sync(callback)
}

///|
extern "js" fn react_prefetch_dns(href : String) -> Unit =
  #| (href) => { globalThis.ReactDOM.prefetchDNS(href); }

///|
/// Hints that the browser may resolve the host in `href` ahead of use.
/// Equivalent calls for the same server are deduplicated by React. During SSR,
/// call this only while rendering or in async work originating from rendering.
pub fn prefetch_dns(href : String) -> Unit {
  react_prefetch_dns(href)
}

///|
extern "js" fn react_preconnect(
  href : String,
  cross_origin : @dom.JsObscure,
) -> Unit =
  #| (href, crossOrigin) => {
  #|   globalThis.ReactDOM.preconnect(
  #|     href,
  #|     crossOrigin == null ? undefined : { crossOrigin },
  #|   );
  #| }

///|
/// Hints that the browser may open an early connection to the server in
/// `href`. Use `cross_origin` when the eventual request uses CORS. Equivalent
/// calls for the same server have the effect of one call.
pub fn preconnect(href : String, cross_origin? : ResourceCrossOrigin) -> Unit {
  react_preconnect(href, optional_cross_origin(cross_origin))
}

///|
extern "js" fn react_preload(href : String, options : @dom.JsObscure) -> Unit =
  #| (href, options) => { globalThis.ReactDOM.preload(href, options); }

///|
/// Hints that the browser should start downloading `href` with the configured
/// destination and metadata. Prefer framework resource management when one is
/// present; frameworks commonly emit and deduplicate these hints themselves.
pub fn preload(href : String, options : PreloadOptions) -> Unit {
  react_preload(href, options.js_value)
}

///|
extern "js" fn react_preload_module(
  href : String,
  options : @dom.JsObscure,
) -> Unit =
  #| (href, options) => { globalThis.ReactDOM.preloadModule(href, options); }

///|
/// Hints that the browser should download the ESM module at `href` without
/// evaluating it. Use `preinit_module` when it should execute when ready.
pub fn preload_module(href : String, options? : ModuleHintOptions) -> Unit {
  let js_options = match options {
    Some(value) => value.js_value
    None =>
      react_module_hint_options(
        @dom.JsObscure::null(),
        @dom.JsObscure::null(),
        @dom.JsObscure::null(),
      )
  }
  react_preload_module(href, js_options)
}

///|
extern "js" fn react_preinit(href : String, options : @dom.JsObscure) -> Unit =
  #| (href, options) => { globalThis.ReactDOM.preinit(href, options); }

///|
/// Hints that the browser should download and immediately apply a stylesheet
/// or execute a classic script. Select the matching `PreinitOptions`
/// constructor; use `preload` when the resource must not take effect yet.
pub fn preinit(href : String, options : PreinitOptions) -> Unit {
  react_preinit(href, options.js_value)
}

///|
extern "js" fn react_preinit_module(
  href : String,
  options : @dom.JsObscure,
) -> Unit =
  #| (href, options) => { globalThis.ReactDOM.preinitModule(href, options); }

///|
/// Hints that the browser should download and evaluate the ESM module at
/// `href`. Use `preload_module` when evaluation should wait. Framework-managed
/// applications usually do not need to call this API directly.
pub fn preinit_module(href : String, options? : ModuleHintOptions) -> Unit {
  let js_options = match options {
    Some(value) => value.js_value
    None =>
      react_module_hint_options(
        @dom.JsObscure::null(),
        @dom.JsObscure::null(),
        @dom.JsObscure::null(),
      )
  }
  react_preinit_module(href, js_options)
}

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
