///|
extern "js" fn install_test_react() -> Unit =
  #| () => {
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createContext: (defaultValue) => ({ defaultValue, currentValue: defaultValue }),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|       cloneElement: (node, props) => ({ ...node, props: { ...node.props, ...props } }),
  #|       useContext: (context) => context.currentValue,
  #|     },
  #|   };
  #|   globalThis.React = globalThis.window.React;
  #| }

///|
extern "js" fn install_component_identity_test_react() -> Unit =
  #| () => {
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) => ({ tag, props, children }),
  #|       cloneElement: (node, props) => ({ ...node, props: { ...node.props, ...props } }),
  #|     },
  #|   };
  #|   globalThis.React = globalThis.window.React;
  #| }

///|
enum NonDefaultReducerState {
  Initial
  Updated
} derive(Eq)

///|
struct ComponentApiProps {
  label : String
}

///|
fn comp_component_api_test(props : ComponentApiProps) -> VirtualNode {
  span([Text(props.label)])
}

///|
extern "js" fn install_component_api_test_react() -> Unit =
  #| () => {
  #|   const Suspense = Symbol("Suspense");
  #|   const Activity = Symbol("Activity");
  #|   globalThis.React = {
  #|     Suspense,
  #|     Activity,
  #|     Component: class {},
  #|     createElement: (tag, props, ...children) => ({ tag, props, children }),
  #|     memo: (component, compare) => ({
  #|       kind: "memo",
  #|       component,
  #|       compare: compare ?? null,
  #|     }),
  #|     lazy: (load) => ({ kind: "lazy", load }),
  #|     use: (resource) => resource.__testValue,
  #|   };
  #|   globalThis.__moonbitTestSuspense = Suspense;
  #|   globalThis.__moonbitTestActivity = Activity;
  #|   globalThis.__moonbitReactComponentTypes = new WeakMap();
  #| }

///|
extern "js" fn test_js_component() -> @dom.JsObscure =
  #| () => (props) => ({
  #|   tag: "js-component",
  #|   props: { received: props.moonbitProps },
  #|   children: [],
  #| })

///|
extern "js" fn test_component_kind(node : @dom.JsObscure) -> String =
  #| (node) => node.tag?.kind ?? "component"

///|
extern "js" fn test_lazy_loader_returns_promise(node : @dom.JsObscure) -> Bool =
  #| (node) => typeof node.tag.load()?.then === "function"

///|
extern "js" fn test_memo_has_custom_compare(node : @dom.JsObscure) -> Bool =
  #| (node) => typeof node.tag?.compare === "function"

///|
extern "js" fn test_memo_compare(
  node : @dom.JsObscure,
  previous : @dom.JsObscure,
  next : @dom.JsObscure,
) -> Bool =
  #| (node, previous, next) => node.tag.compare(
  #|   { moonbitProps: previous },
  #|   { moonbitProps: next },
  #| )

///|
extern "js" fn test_suspense_tag_matches(node : @dom.JsObscure) -> Bool =
  #| (node) => node.tag === globalThis.__moonbitTestSuspense

///|
extern "js" fn test_activity_tag_matches(node : @dom.JsObscure) -> Bool =
  #| (node) => node.tag === globalThis.__moonbitTestActivity

///|
extern "js" fn test_resource_promise(
  state : String,
  value : String,
) -> @js_async.Promise[String] =
  #| (state, value) => ({
  #|   __testState: state,
  #|   __testValue: value,
  #|   then() {},
  #| })

///|
extern "js" fn test_resource_state(resource : @dom.JsObscure) -> String =
  #| (resource) => resource.__testState

///|
extern "js" fn test_resource_identity(
  resource : @dom.JsObscure,
  promise : @js_async.Promise[String],
) -> Bool =
  #| (resource, promise) => resource === promise

///|
extern "js" fn test_resource_is_thenable(resource : @dom.JsObscure) -> Bool =
  #| (resource) => typeof resource?.then === "function"

///|
extern "js" fn test_error_boundary_tag_matches(node : @dom.JsObscure) -> Bool =
  #| (node) => node.tag === globalThis.__moonbitReactErrorBoundary

///|
extern "js" fn test_error_boundary_reset_key(node : @dom.JsObscure) -> String =
  #| (node) => node.props.resetKey

///|
extern "js" fn test_error_boundary_has_on_error(node : @dom.JsObscure) -> Bool =
  #| (node) => typeof node.props.onError === "function"

///|
extern "js" fn test_error_boundary_fallback(
  node : @dom.JsObscure,
  message : String,
) -> @dom.JsObscure =
  #| (node, message) => node.props.fallback(new Error(message))

///|
extern "js" fn test_js_component_received_label(
  node : @dom.JsObscure,
) -> String =
  #| (node) => node.props.received.label

///|
extern "js" fn react_element_child_count(node : @dom.JsObscure) -> Int =
  #| (node) => node.children.length

///|
extern "js" fn react_element_child(
  node : @dom.JsObscure,
  index : Int,
) -> @dom.JsObscure =
  #| (node, index) => node.children[index]

///|
extern "js" fn react_element_string_prop(
  node : @dom.JsObscure,
  key : String,
) -> String =
  #| (node, key) => node.props[key] || ""

///|
extern "js" fn react_element_string_array_prop(
  node : @dom.JsObscure,
  key : String,
) -> String =
  #| (node, key) => {
  #|   const value = node?.props?.[key];
  #|   return Array.isArray(value) ? value.join("|") : "";
  #| }

///|
extern "js" fn js_value_string_prop(
  value : @dom.JsObscure,
  key : String,
) -> String =
  #| (value, key) => value[key] || ""

///|
extern "js" fn react_element_tag(node : @dom.JsObscure) -> String =
  #| (node) => node.tag

///|
extern "js" fn react_element_tag_equals(
  node : @dom.JsObscure,
  tag : @dom.JsObscure,
) -> Bool =
  #| (node, tag) => node.tag === tag

///|
extern "js" fn react_elements_have_same_tag(
  first : @dom.JsObscure,
  second : @dom.JsObscure,
) -> Bool =
  #| (first, second) => first.tag === second.tag

///|
extern "js" fn render_test_component_factory(
  node : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (node) => node.tag(node.props)

///|
extern "js" fn react_element_first_child_string(
  node : @dom.JsObscure,
) -> String =
  #| (node) => node.children[0]

///|
extern "js" fn react_element_bool_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => node.props[key] === true

///|
extern "js" fn react_element_has_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => Object.hasOwn(node.props, key)

///|
extern "js" fn react_element_prop_equals(
  node : @dom.JsObscure,
  key : String,
  value : @dom.JsObscure,
) -> Bool =
  #| (node, key, value) => node.props[key] === value

///|
extern "js" fn react_element_has_function_prop(
  node : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (node, key) => typeof node.props[key] === "function"

///|
extern "js" fn react_element_int_prop(
  node : @dom.JsObscure,
  key : String,
) -> Int =
  #| (node, key) => node.props[key]

///|
extern "js" fn react_element_number_prop_matches(
  node : @dom.JsObscure,
  key : String,
  expected : Float,
) -> Bool =
  #| (node, key, expected) => node.props[key] === expected

///|
extern "js" fn react_element_inner_html(node : @dom.JsObscure) -> String =
  #| (node) => node.props.dangerouslySetInnerHTML?.__html || ""

///|
extern "js" fn js_value_has_function_prop(
  value : @dom.JsObscure,
  key : String,
) -> Bool =
  #| (value, key) => typeof value[key] === "function"

///|
extern "js" fn js_value_bool(value : @dom.JsObscure) -> Bool =
  #| (value) => value === true

///|
extern "js" fn js_value_string(value : @dom.JsObscure) -> String =
  #| (value) => value

///|
extern "js" fn test_dom_event() -> DOMEvent =
  #| () => ({
  #|   target: { value: "updated value", checked: true },
  #|   key: "Enter",
  #|   keyCode: 13,
  #|   clientX: 24,
  #|   clientY: 48,
  #|   ctrlKey: true,
  #|   shiftKey: true,
  #|   altKey: true,
  #|   metaKey: true,
  #|   nativeEvent: {
  #|     pointerId: 17,
  #|     button: 1,
  #|     buttons: 3,
  #|     pressure: 0.5,
  #|     clientX: 24.5,
  #|     clientY: 48.5,
  #|   },
  #|   preventDefault() { this.defaultPrevented = true; },
  #|   stopPropagation() { this.propagationStopped = true; },
  #| })

///|
extern "js" fn test_wheel_dom_event() -> DOMEvent =
  #| () => ({
  #|   nativeEvent: { deltaX: 1.5, deltaY: -2.5, deltaMode: 1 },
  #| })

///|
extern "js" fn test_generic_dom_event() -> DOMEvent =
  #| () => ({ nativeEvent: { type: "submit" } })

///|
extern "js" fn test_dom_event_default_prevented(event : DOMEvent) -> Bool =
  #| (event) => event.defaultPrevented === true

///|
extern "js" fn test_dom_event_propagation_stopped(event : DOMEvent) -> Bool =
  #| (event) => event.propagationStopped === true

///|
extern "js" fn react_element_trigger_event(
  node : @dom.JsObscure,
  handler_name : String,
  event : DOMEvent,
) -> Unit =
  #| (node, handlerName, event) => node.props[handlerName](event)

///|
extern "js" fn install_test_react_dom() -> Unit =
  #| () => {
  #|   let createRootCalls = 0;
  #|   let renderCalls = 0;
  #|   let unmountCalls = 0;
  #|   let hydrateRootCalls = 0;
  #|   let createRootOptions = null;
  #|   let hydrateRootOptions = null;
  #|   let portalCall = null;
  #|   let serverRenderPrefix = null;
  #|   let flushSyncCalls = 0;
  #|   const operationCalls = [];
  #|   globalThis.ReactDOMClient = {
  #|     createRoot: (_parent, options) => {
  #|       createRootCalls += 1;
  #|       createRootOptions = options;
  #|       return {
  #|         render: () => { renderCalls += 1; },
  #|         unmount: () => { unmountCalls += 1; },
  #|       };
  #|     },
  #|     hydrateRoot: (_parent, _vdom, options) => {
  #|       hydrateRootCalls += 1;
  #|       hydrateRootOptions = options;
  #|       return {
  #|         render: () => { renderCalls += 1; },
  #|         unmount: () => { unmountCalls += 1; },
  #|       };
  #|     },
  #|   };
  #|   globalThis.ReactDOM = {
  #|     createPortal: (child, parent, key) => {
  #|       portalCall = { child, parent, key };
  #|       return { portal: true, child, parent, key };
  #|     },
  #|     flushSync: (callback) => {
  #|       flushSyncCalls += 1;
  #|       callback();
  #|     },
  #|     prefetchDNS: (href) => operationCalls.push({ name: "prefetchDNS", href }),
  #|     preconnect: (href, options) => operationCalls.push({ name: "preconnect", href, options }),
  #|     preload: (href, options) => operationCalls.push({ name: "preload", href, options }),
  #|     preloadModule: (href, options) => operationCalls.push({ name: "preloadModule", href, options }),
  #|     preinit: (href, options) => operationCalls.push({ name: "preinit", href, options }),
  #|     preinitModule: (href, options) => operationCalls.push({ name: "preinitModule", href, options }),
  #|   };
  #|   globalThis.ReactDOMServer = {
  #|     renderToString: (_vdom, options) => {
  #|       serverRenderPrefix = options?.identifierPrefix ?? null;
  #|       return `<main>${serverRenderPrefix ?? "none"}</main>`;
  #|     },
  #|   };
  #|   globalThis.__moonbitReactRoots = new WeakMap();
  #|   globalThis.__moonbitReactRenderCounts = () =>
  #|     [createRootCalls, renderCalls, unmountCalls, hydrateRootCalls];
  #|   globalThis.__moonbitReactRootTestValues = () => ({
  #|     createRootOptions,
  #|     hydrateRootOptions,
  #|     portalCall,
  #|     serverRenderPrefix,
  #|   });
  #|   globalThis.__moonbitReactDomOperationTest = {
  #|     flushSyncCalls: () => flushSyncCalls,
  #|     calls: operationCalls,
  #|   };
  #| }

///|
extern "js" fn test_flush_sync_count() -> Int =
  #| () => globalThis.__moonbitReactDomOperationTest.flushSyncCalls()

///|
extern "js" fn test_dom_operation_count(name : String) -> Int =
  #| (name) => globalThis.__moonbitReactDomOperationTest.calls
  #|   .filter((call) => call.name === name).length

///|
extern "js" fn test_dom_operation_href(name : String, index : Int) -> String =
  #| (name, index) => globalThis.__moonbitReactDomOperationTest.calls
  #|   .filter((call) => call.name === name)[index]?.href ?? ""

///|
extern "js" fn test_dom_operation_option(
  name : String,
  index : Int,
  option : String,
) -> String =
  #| (name, index, option) => String(
  #|   globalThis.__moonbitReactDomOperationTest.calls
  #|     .filter((call) => call.name === name)[index]?.options?.[option] ?? "",
  #| )

///|
extern "js" fn install_test_stream_renderer() -> Unit =
  #| () => {
  #|   globalThis.__moonbitStreamTest = {
  #|     options: null,
  #|     aborts: 0,
  #|   };
  #|   globalThis.ReactDOMServer.renderToReadableStream = async (vdom, options) => {
  #|     globalThis.__moonbitStreamTest.options = options;
  #|     options.signal.addEventListener("abort", () => {
  #|       globalThis.__moonbitStreamTest.aborts += 1;
  #|     });
  #|     options.onError?.(new Error("reported stream error"));
  #|     const stream = new ReadableStream({
  #|       start(controller) {
  #|         controller.enqueue(new TextEncoder().encode(`streamed:${vdom}`));
  #|         controller.close();
  #|       },
  #|     });
  #|     stream.allReady = Promise.resolve();
  #|     return stream;
  #|   };
  #| }

///|
extern "js" fn test_stream_identifier_prefix() -> String =
  #| () => globalThis.__moonbitStreamTest.options?.identifierPrefix ?? ""

///|
extern "js" fn test_stream_bootstrap_script_count() -> Int =
  #| () => globalThis.__moonbitStreamTest.options?.bootstrapScripts?.length ?? 0

///|
extern "js" fn test_stream_bootstrap_module_count() -> Int =
  #| () => globalThis.__moonbitStreamTest.options?.bootstrapModules?.length ?? 0

///|
extern "js" fn test_stream_nonce() -> String =
  #| () => globalThis.__moonbitStreamTest.options?.nonce ?? ""

///|
extern "js" fn test_stream_abort_count() -> Int =
  #| () => globalThis.__moonbitStreamTest.aborts

///|
extern "js" fn test_is_readable_stream(
  stream : @js_async.JsReadableStream,
) -> Bool =
  #| (stream) => typeof stream?.getReader === "function"

///|
extern "js" fn test_parent_element() -> @dom.Element =
  #| () => ({})

///|
extern "js" fn react_render_create_root_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[0]

///|
extern "js" fn react_render_call_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[1]

///|
extern "js" fn react_unmount_call_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[2]

///|
extern "js" fn react_hydrate_root_call_count() -> Int =
  #| () => globalThis.__moonbitReactRenderCounts()[3]

///|
extern "js" fn test_create_root_identifier_prefix() -> String =
  #| () => globalThis.__moonbitReactRootTestValues()
  #|   .createRootOptions?.identifierPrefix ?? ""

///|
extern "js" fn test_create_root_callback_count() -> Int =
  #| () => {
  #|   const options = globalThis.__moonbitReactRootTestValues().createRootOptions;
  #|   return [
  #|     options?.onCaughtError,
  #|     options?.onUncaughtError,
  #|     options?.onRecoverableError,
  #|   ].filter((value) => typeof value === "function").length;
  #| }

///|
extern "js" fn test_hydrate_root_identifier_prefix() -> String =
  #| () => globalThis.__moonbitReactRootTestValues()
  #|   .hydrateRootOptions?.identifierPrefix ?? ""

///|
extern "js" fn test_portal_child() -> String =
  #| () => globalThis.__moonbitReactRootTestValues().portalCall?.child ?? ""

///|
extern "js" fn test_portal_key() -> String =
  #| () => globalThis.__moonbitReactRootTestValues().portalCall?.key ?? ""

///|
extern "js" fn test_server_render_prefix() -> String =
  #| () => globalThis.__moonbitReactRootTestValues().serverRenderPrefix ?? ""

///|
extern "js" fn test_react_error() -> ReactError =
  #| () => new Error("root failed")

///|
extern "js" fn test_react_error_info() -> ReactErrorInfo =
  #| () => ({ componentStack: "\n    at MoonBitProbe" })

///|
extern "js" fn install_test_react_hooks() -> Unit =
  #| () => {
  #|   globalThis.__moonbitHookState = {
  #|     state: null,
  #|     reduced: null,
  #|     optimistic: null,
  #|     transitionActions: 0,
  #|     externalServerSnapshot: null,
  #|     imperativeDeps: 0,
  #|   };
  #|   const runTransition = (action) => {
  #|     globalThis.__moonbitHookState.transitionActions += 1;
  #|     action();
  #|   };
  #|   const runEffect = (effect) => {
  #|     const cleanup = effect();
  #|     if (typeof cleanup === "function") cleanup();
  #|   };
  #|   const submittedFormData = new FormData();
  #|   submittedFormData.append("field", "submitted");
  #|   globalThis.__moonbitFormStatus = {
  #|     pending: true,
  #|     data: submittedFormData,
  #|     method: "post",
  #|     action: () => {},
  #|   };
  #|   globalThis.window = {
  #|     React: {
  #|       Fragment: Symbol("Fragment"),
  #|       createElement: (tag, props, ...children) =>
  #|         typeof tag === "function" ? tag(props) : ({ tag, props, children }),
  #|       useState: (initial) => {
  #|         let current = initial;
  #|         return [initial, (value) => {
  #|           current = typeof value === "function" ? value(current) : value;
  #|           globalThis.__moonbitHookState.state = current;
  #|         }];
  #|       },
  #|       useEffect: runEffect,
  #|       useLayoutEffect: runEffect,
  #|       useMemo: (factory) => factory(),
  #|       useCallback: (callback) => callback,
  #|       useEffectEvent: (callback) => callback,
  #|       useActionState: (action, initial) => [initial, (value) => {
  #|         globalThis.__moonbitHookState.reduced = action(initial, value);
  #|       }, false],
  #|       useOptimistic: (initial, reducer) => [initial, (value) => {
  #|         globalThis.__moonbitHookState.optimistic = reducer(initial, value);
  #|       }],
  #|       useRef: (initial) => ({ current: initial }),
  #|       useId: () => "moonbit-test-id",
  #|       useDeferredValue: (value) => value,
  #|       useTransition: () => [false, runTransition],
  #|       startTransition: runTransition,
  #|       useSyncExternalStore: (subscribe, getSnapshot, getServerSnapshot) => {
  #|         globalThis.__moonbitHookState.externalServerSnapshot =
  #|           getServerSnapshot?.() ?? null;
  #|         const cleanup = subscribe(() => {});
  #|         if (typeof cleanup === "function") cleanup();
  #|         return getSnapshot();
  #|       },
  #|       useImperativeHandle: (ref, createHandle, deps) => {
  #|         ref.current = createHandle();
  #|         globalThis.__moonbitHookState.imperativeDeps = deps.length;
  #|       },
  #|       useReducer: (reducer, initial) => [initial, (action) => {
  #|         globalThis.__moonbitHookState.reduced = reducer(initial, action);
  #|       }],
  #|     },
  #|     ReactDOM: {
  #|       useFormStatus: () => globalThis.__moonbitFormStatus,
  #|     },
  #|   };
  #|   globalThis.React = globalThis.window.React;
  #|   globalThis.ReactDOM = globalThis.window.ReactDOM;
  #| }

///|
extern "js" fn hook_test_state() -> Int =
  #| () => globalThis.__moonbitHookState.state

///|
extern "js" fn hook_test_reduced_state() -> Int =
  #| () => globalThis.__moonbitHookState.reduced

///|
extern "js" fn hook_test_transition_action_count() -> Int =
  #| () => globalThis.__moonbitHookState.transitionActions

///|
extern "js" fn hook_test_optimistic_state() -> Int =
  #| () => globalThis.__moonbitHookState.optimistic

///|
extern "js" fn hook_test_reduced_is_promise() -> Bool =
  #| () => typeof globalThis.__moonbitHookState.reduced?.then === "function"

///|
extern "js" fn hook_test_external_server_snapshot() -> Int =
  #| () => globalThis.__moonbitHookState.externalServerSnapshot

///|
extern "js" fn hook_test_imperative_dep_count() -> Int =
  #| () => globalThis.__moonbitHookState.imperativeDeps

///|
extern "js" fn test_form_data() -> ReactFormData =
  #| () => {
  #|   const data = new FormData();
  #|   data.append("field", "value");
  #|   data.append("attachment", new File(["fixture"], "fixture.txt"));
  #|   return data;
  #| }

///|
extern "js" fn react_element_function_prop_returns_promise(
  node : @dom.JsObscure,
  key : String,
  data : ReactFormData,
) -> Bool =
  #| (node, key, data) => {
  #|   const result = node.props[key](data);
  #|   return typeof result?.then === "function";
  #| }

///|
extern "js" fn test_resolved_unit_promise() -> @js_async.Promise[Unit] =
  #| () => Promise.resolve(undefined)

///|
extern "js" fn test_resolved_int_promise(value : Int) -> @js_async.Promise[Int] =
  #| (value) => Promise.resolve(value)

///|
extern "js" fn set_test_form_status_action_present(present : Bool) -> Unit =
  #| (present) => {
  #|   globalThis.__moonbitFormStatus.action = present ? () => {} : null;
  #| }

///|
extern "js" fn set_test_dom_ref(
  js_ref : @dom.JsObscure,
  mounted : Bool,
) -> Unit =
  #| (jsRef, mounted) => {
  #|   jsRef.current = mounted ? { tagName: "INPUT" } : null;
  #| }

///|
extern "js" fn test_callback_throws(callback : () -> Unit) -> Bool =
  #| (callback) => {
  #|   try {
  #|     callback();
  #|     return false;
  #|   } catch (_) {
  #|     return true;
  #|   }
  #| }

///|
extern "js" fn install_test_style_document() -> Unit =
  #| () => {
  #|   const tags = [];
  #|   const head = { appendChild: (tag) => { tags.push(tag); } };
  #|   globalThis.window = {
  #|     document: {
  #|       head,
  #|       createElement: () => {
  #|         const tag = { attributes: {} };
  #|         tag.setAttribute = (key, value) => { tag.attributes[key] = value; };
  #|         return tag;
  #|       },
  #|     },
  #|   };
  #|   globalThis.__moonbitStyleTags = tags;
  #| }

///|
extern "js" fn clear_test_window() -> Unit =
  #| () => { delete globalThis.window; }

///|
extern "js" fn test_style_tag_count() -> Int =
  #| () => globalThis.__moonbitStyleTags.length

///|
extern "js" fn test_style_tag_contains(index : Int, text : String) -> Bool =
  #| (index, text) => globalThis.__moonbitStyleTags[index].innerHTML.includes(text)

///|
fn static_style_for_test() -> String {
  static_style([("&", @css.respo_style(color=@css.CssColor::Blue))])
}

///|
fn static_style_without_document_for_test() -> String {
  static_style([("&", @css.respo_style(color=@css.CssColor::Purple))])
}

///|
fn contained_static_style_for_test() -> String {
  contained_static_style([
    (
      Some("@media (min-width: 640px)"),
      "&:hover",
      @css.respo_style(color=@css.CssColor::Red),
    ),
  ])
}

///|
fn contained_static_style_without_container_for_test() -> String {
  contained_static_style([
    (None, "&:focus", @css.respo_style(color=@css.CssColor::Green)),
  ])
}

///|
fn contained_static_style_without_document_for_test() -> String {
  contained_static_style([
    (None, "&:focus", @css.respo_style(color=@css.CssColor::Purple)),
  ])
}

///|
test "DOM attribute names use React property names" {
  inspect(dom_attr_to_react_prop("class"), content="className")
  inspect(dom_attr_to_react_prop("for"), content="htmlFor")
  inspect(
    dom_attr_to_react_prop("innerHTML"),
    content="dangerouslySetInnerHTML",
  )
  inspect(dom_attr_to_react_prop("data-testid"), content="data-testid")
}

///|
test "CSS property names convert to React camel case" {
  inspect(css_prop_to_camel_case("background-color"), content="backgroundColor")
  inspect(
    css_prop_to_camel_case("-webkit-line-clamp"),
    content="WebkitLineClamp",
  )
  inspect(css_prop_to_camel_case("font"), content="font")
  inspect(css_prop_to_camel_case(""), content="")
}

///|
test "Respo styles convert to React style objects" {
  let style = convert_style_to_js_object(
    @css.respo_style(color=@css.CssColor::Blue, font_size=16),
  ).to_js_obscure()
  inspect(js_value_string_prop(style, "color"), content="blue")
  inspect(js_value_string_prop(style, "fontSize"), content="16px")
}

///|
test "static styles inject once per callsite" {
  install_test_style_document()
  let first = static_style_for_test()
  let second = static_style_for_test()
  assert_eq(first, second)
  inspect(test_style_tag_count(), content="1")
  inspect(test_style_tag_contains(0, "." + first), content="true")
  inspect(test_style_tag_contains(0, "color"), content="true")
  inspect(test_style_tag_contains(0, "blue"), content="true")
}

///|
test "static styles defer injection without a document" {
  clear_test_window()
  let static_class_name = static_style_without_document_for_test()
  let contained_class_name = contained_static_style_without_document_for_test()

  install_test_style_document()
  assert_eq(static_style_without_document_for_test(), static_class_name)
  assert_eq(
    contained_static_style_without_document_for_test(),
    contained_class_name,
  )
  inspect(test_style_tag_count(), content="2")
  inspect(test_style_tag_contains(0, "." + static_class_name), content="true")
  inspect(
    test_style_tag_contains(1, "." + contained_class_name + ":focus"),
    content="true",
  )
}

///|
test "contained static styles preserve their container and selector" {
  install_test_style_document()
  let class_name = contained_static_style_for_test()
  inspect(test_style_tag_count(), content="1")
  inspect(
    test_style_tag_contains(0, "@media (min-width: 640px)"),
    content="true",
  )
  inspect(
    test_style_tag_contains(0, "." + class_name + ":hover"),
    content="true",
  )
  inspect(test_style_tag_contains(0, "red"), content="true")
}

///|
test "contained static styles cache uncontained rules per callsite" {
  install_test_style_document()
  let first = contained_static_style_without_container_for_test()
  let second = contained_static_style_without_container_for_test()
  assert_eq(first, second)
  inspect(test_style_tag_count(), content="1")
  inspect(test_style_tag_contains(0, "." + first + ":focus"), content="true")
  inspect(test_style_tag_contains(0, "green"), content="true")
}

///|
test "DOM events use React handler names" {
  inspect(dom_event_to_react_handler(Click), content="onClick")
  inspect(dom_event_to_react_handler(KeyDown), content="onKeyDown")
  inspect(dom_event_to_react_handler(TouchCancel), content="onTouchCancel")
  inspect(DOMEventType::Click.to_string(), content="click")
}

///|
test "all DOM event types map to native and React names" {
  let cases : Array[(DOMEventType, String, String)] = [
    (DOMEventType::Copy, "copy", "onCopy"),
    (DOMEventType::Cut, "cut", "onCut"),
    (DOMEventType::Paste, "paste", "onPaste"),
    (DOMEventType::CompositionEnd, "compositionend", "onCompositionEnd"),
    (DOMEventType::CompositionStart, "compositionstart", "onCompositionStart"),
    (
      DOMEventType::CompositionUpdate,
      "compositionupdate",
      "onCompositionUpdate",
    ),
    (DOMEventType::Click, "click", "onClick"),
    (DOMEventType::DoubleClick, "dblclick", "onDoubleClick"),
    (DOMEventType::MouseDown, "mousedown", "onMouseDown"),
    (DOMEventType::MouseUp, "mouseup", "onMouseUp"),
    (DOMEventType::MouseMove, "mousemove", "onMouseMove"),
    (DOMEventType::MouseEnter, "mouseenter", "onMouseEnter"),
    (DOMEventType::MouseLeave, "mouseleave", "onMouseLeave"),
    (DOMEventType::MouseOver, "mouseover", "onMouseOver"),
    (DOMEventType::MouseOut, "mouseout", "onMouseOut"),
    (DOMEventType::ContextMenu, "contextmenu", "onContextMenu"),
    (DOMEventType::PointerDown, "pointerdown", "onPointerDown"),
    (DOMEventType::PointerMove, "pointermove", "onPointerMove"),
    (DOMEventType::PointerUp, "pointerup", "onPointerUp"),
    (DOMEventType::PointerCancel, "pointercancel", "onPointerCancel"),
    (DOMEventType::PointerEnter, "pointerenter", "onPointerEnter"),
    (DOMEventType::PointerLeave, "pointerleave", "onPointerLeave"),
    (DOMEventType::PointerOver, "pointerover", "onPointerOver"),
    (DOMEventType::PointerOut, "pointerout", "onPointerOut"),
    (
      DOMEventType::GotPointerCapture,
      "gotpointercapture",
      "onGotPointerCapture",
    ),
    (
      DOMEventType::LostPointerCapture,
      "lostpointercapture",
      "onLostPointerCapture",
    ),
    (DOMEventType::KeyDown, "keydown", "onKeyDown"),
    (DOMEventType::KeyUp, "keyup", "onKeyUp"),
    (DOMEventType::KeyPress, "keypress", "onKeyPress"),
    (DOMEventType::BeforeInput, "beforeinput", "onBeforeInput"),
    (DOMEventType::Input, "input", "onInput"),
    (DOMEventType::Change, "change", "onChange"),
    (DOMEventType::Submit, "submit", "onSubmit"),
    (DOMEventType::Reset, "reset", "onReset"),
    (DOMEventType::Focus, "focus", "onFocus"),
    (DOMEventType::Blur, "blur", "onBlur"),
    (DOMEventType::Select, "select", "onSelect"),
    (DOMEventType::Load, "load", "onLoad"),
    (DOMEventType::Unload, "unload", "onUnload"),
    (DOMEventType::Resize, "resize", "onResize"),
    (DOMEventType::Scroll, "scroll", "onScroll"),
    (DOMEventType::Wheel, "wheel", "onWheel"),
    (DOMEventType::Drag, "drag", "onDrag"),
    (DOMEventType::DragStart, "dragstart", "onDragStart"),
    (DOMEventType::DragEnd, "dragend", "onDragEnd"),
    (DOMEventType::DragEnter, "dragenter", "onDragEnter"),
    (DOMEventType::DragLeave, "dragleave", "onDragLeave"),
    (DOMEventType::DragOver, "dragover", "onDragOver"),
    (DOMEventType::Drop, "drop", "onDrop"),
    (DOMEventType::TouchStart, "touchstart", "onTouchStart"),
    (DOMEventType::TouchMove, "touchmove", "onTouchMove"),
    (DOMEventType::TouchEnd, "touchend", "onTouchEnd"),
    (DOMEventType::TouchCancel, "touchcancel", "onTouchCancel"),
    (DOMEventType::Error, "error", "onError"),
    (DOMEventType::Abort, "abort", "onAbort"),
    (DOMEventType::CanPlay, "canplay", "onCanPlay"),
    (DOMEventType::CanPlayThrough, "canplaythrough", "onCanPlayThrough"),
    (DOMEventType::DurationChange, "durationchange", "onDurationChange"),
    (DOMEventType::Ended, "ended", "onEnded"),
    (DOMEventType::LoadedData, "loadeddata", "onLoadedData"),
    (DOMEventType::LoadedMetadata, "loadedmetadata", "onLoadedMetadata"),
    (DOMEventType::LoadStart, "loadstart", "onLoadStart"),
    (DOMEventType::Pause, "pause", "onPause"),
    (DOMEventType::Play, "play", "onPlay"),
    (DOMEventType::Playing, "playing", "onPlaying"),
    (DOMEventType::Progress, "progress", "onProgress"),
    (DOMEventType::RateChange, "ratechange", "onRateChange"),
    (DOMEventType::Seeked, "seeked", "onSeeked"),
    (DOMEventType::Seeking, "seeking", "onSeeking"),
    (DOMEventType::Stalled, "stalled", "onStalled"),
    (DOMEventType::Suspend, "suspend", "onSuspend"),
    (DOMEventType::TimeUpdate, "timeupdate", "onTimeUpdate"),
    (DOMEventType::VolumeChange, "volumechange", "onVolumeChange"),
    (DOMEventType::Waiting, "waiting", "onWaiting"),
    (DOMEventType::AnimationStart, "animationstart", "onAnimationStart"),
    (DOMEventType::AnimationEnd, "animationend", "onAnimationEnd"),
    (
      DOMEventType::AnimationIteration,
      "animationiteration",
      "onAnimationIteration",
    ),
    (DOMEventType::TransitionEnd, "transitionend", "onTransitionEnd"),
    (DOMEventType::Invalid, "invalid", "onInvalid"),
    (DOMEventType::Toggle, "toggle", "onToggle"),
  ]
  for case in cases {
    let (event_type, native_name, react_name) = case
    assert_eq(event_type.to_string(), native_name)
    assert_eq(dom_event_to_react_handler(event_type), react_name)
  }
  inspect(DOMEventType::Click, content="click")
}

///|
test "ElementEvents serializes React handler property names" {
  let events = ElementEvents::new().add(Click, fn(_event) {  })
  inspect(
    js_value_has_function_prop(events.to_js_value(), "onClick"),
    content="true",
  )
}

///|
test "all built-in element helpers emit their HTML tag" {
  install_test_react()
  let cases : Array[(VirtualNode, String)] = [
    (span([]), "span"),
    (p([]), "p"),
    (label([]), "label"),
    (h1([]), "h1"),
    (h2([]), "h2"),
    (h3([]), "h3"),
    (h4([]), "h4"),
    (h5([]), "h5"),
    (h6([]), "h6"),
    (a([]), "a"),
    (div([]), "div"),
    (input(), "input"),
    (button([]), "button"),
    (textarea(), "textarea"),
    (select([]), "select"),
    (option([]), "option"),
    (section([]), "section"),
    (article([]), "article"),
    (header([]), "header"),
    (footer([]), "footer"),
    (nav([]), "nav"),
    (aside([]), "aside"),
    (ul([]), "ul"),
    (ol([]), "ol"),
    (li([]), "li"),
    (img(), "img"),
    (video([]), "video"),
    (audio([]), "audio"),
  ]
  for case in cases {
    let (node, tag) = case
    assert_eq(react_element_tag(node.to_js_obscure()), tag)
  }
}

///|
test "text, structure, and list helpers preserve common optional props" {
  install_test_react()
  let nodes : Array[VirtualNode] = [
    p(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h1(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h2(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h3(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h4(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h5(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    h6(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    a(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    div(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    section(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    article(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    header(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    footer(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    nav(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    aside(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    ul(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    ol(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
    li(
      id="common-id",
      class_name="base",
      class_list=["extra-class"],
      innerHTML="<em>trusted</em>",
      on_click=fn(_event) {  },
      [],
    ),
  ]
  for node in nodes {
    let value = node.to_js_obscure()
    assert_eq(react_element_string_prop(value, "id"), "common-id")
    assert_eq(react_element_string_prop(value, "className"), "base extra-class")
    assert_eq(react_element_inner_html(value), "<em>trusted</em>")
    assert_eq(react_element_has_function_prop(value, "onClick"), true)
  }

  let label_node = label(
    id="common-id",
    class_name="base",
    class_list=["extra-class"],
    innerHTML="<em>trusted</em>",
    on_click=fn(_event) {  },
    for_="input-id",
    [],
  ).to_js_obscure()
  assert_eq(react_element_string_prop(label_node, "id"), "common-id")
  assert_eq(
    react_element_string_prop(label_node, "className"),
    "base extra-class",
  )
  assert_eq(react_element_inner_html(label_node), "<em>trusted</em>")
  assert_eq(react_element_has_function_prop(label_node, "onClick"), true)
  inspect(react_element_string_prop(label_node, "htmlFor"), content="input-id")
}

///|
test "input types use valid HTML values" {
  inspect(InputType::Button.to_string(), content="button")
  inspect(InputType::Checkbox.to_string(), content="checkbox")
  inspect(InputType::Color.to_string(), content="color")
  inspect(InputType::Date.to_string(), content="date")
  inspect(InputType::DatetimeLocal.to_string(), content="datetime-local")
  inspect(InputType::Email.to_string(), content="email")
  inspect(InputType::File.to_string(), content="file")
  inspect(InputType::Hidden.to_string(), content="hidden")
  inspect(InputType::Image.to_string(), content="image")
  inspect(InputType::Month.to_string(), content="month")
  inspect(InputType::Number.to_string(), content="number")
  inspect(InputType::Password.to_string(), content="password")
  inspect(InputType::Radio.to_string(), content="radio")
  inspect(InputType::Range.to_string(), content="range")
  inspect(InputType::Reset.to_string(), content="reset")
  inspect(InputType::Search.to_string(), content="search")
  inspect(InputType::Submit.to_string(), content="submit")
  inspect(InputType::Tel.to_string(), content="tel")
  inspect(InputType::Text.to_string(), content="text")
  inspect(InputType::Time.to_string(), content="time")
  inspect(InputType::Url.to_string(), content="url")
  inspect(InputType::Week.to_string(), content="week")
}

///|
test "boolean React properties are recognized" {
  inspect(is_boolean_prop("checked"), content="true")
  inspect(is_boolean_prop("readOnly"), content="true")
  inspect(is_boolean_prop("className"), content="false")
}

///|
test "legacy boolean string props retain their React value type" {
  inspect(js_value_bool(convert_prop_value("checked", "true")), content="true")
  inspect(
    js_value_bool(convert_prop_value("checked", "false")),
    content="false",
  )
  inspect(
    js_value_string(convert_prop_value("checked", "mixed")),
    content="mixed",
  )
}

///|
test "virtual elements convert each child exactly once" {
  install_test_react()
  let node = create_element(
    "div",
    ElementAttrs::new(),
    ElementEvents::new(),
    style=@css.respo_style(),
    [Text("first"), Text("second")],
  ).to_node()
  inspect(react_element_child_count(node.to_js_obscure()), content="2")
}

///|
test "fragments create React fragment nodes with every child" {
  install_test_react()
  let fragment = VirtualNode::Fragment([
    VirtualNode::Text("first"),
    VirtualNode::Text("second"),
  ]).to_js_obscure()
  inspect(react_element_child_count(fragment), content="2")
}

///|
test "virtual nodes accept stable reconciliation keys" {
  install_test_react()
  let node = div([Text("keyed child")]).with_key("todo-42").to_js_obscure()
  inspect(react_element_string_prop(node, "key"), content="todo-42")
  inspect(react_element_child_count(node), content="1")
  inspect(react_element_tag(node), content="div")
}

///|
test "contexts preserve typed defaults and provider values" {
  install_test_react()
  let context = create_context("fallback")
  inspect(use_context(context), content="fallback")
  let provider = context.provider("provided", [Text("child")]).to_js_obscure()
  inspect(
    react_element_tag_equals(provider, context.to_js_obscure()),
    content="true",
  )
  inspect(react_element_string_prop(provider, "value"), content="provided")
  inspect(react_element_child_count(provider), content="1")
}

///|
test "attributes set through ElementAttrs are converted to React props" {
  install_test_react()
  let attrs = ElementAttrs::new().add("title", "first")
  attrs.set("title", "updated")
  attrs.set_bool("checked", false)
  attrs.set_int("tabIndex", 3)
  let node = create_element(
    "div",
    attrs,
    ElementEvents::new(),
    style=@css.respo_style(),
    [],
  ).to_node()
  inspect(
    react_element_string_prop(node.to_js_obscure(), "title"),
    content="updated",
  )
  inspect(
    react_element_has_prop(node.to_js_obscure(), "checked"),
    content="true",
  )
  inspect(
    react_element_bool_prop(node.to_js_obscure(), "checked"),
    content="false",
  )
  inspect(react_element_int_prop(node.to_js_obscure(), "tabIndex"), content="3")
}

///|
test "generated HTML helpers preserve typed props across required categories" {
  install_test_react()
  let table_node = table(
    class_name="generated",
    class_list=["striped"],
    aria_label="Quarterly scores",
    data_testid="scores",
    [
      caption([Text("Scores")]),
      colgroup(span=2, [col(span=2)]),
      thead([tr([th(scope="col", col_span=2, [Text("Team")])])]),
      tbody([tr([td(headers="team", row_span=2, [Text("MoonBit")])])]),
    ],
  ).to_js_obscure()
  inspect(react_element_tag(table_node), content="table")
  inspect(
    react_element_string_prop(table_node, "className"),
    content="generated striped",
  )
  inspect(
    react_element_string_prop(table_node, "aria-label"),
    content="Quarterly scores",
  )
  inspect(
    react_element_string_prop(table_node, "data-testid"),
    content="scores",
  )
  inspect(react_element_child_count(table_node), content="4")
  let head = react_element_child(table_node, 2)
  let header_row = react_element_child(head, 0)
  let header = react_element_child(header_row, 0)
  inspect(react_element_string_prop(header, "scope"), content="col")
  inspect(react_element_int_prop(header, "colSpan"), content="2")

  let fieldset_node = fieldset(disabled=false, [legend([Text("Profile")])]).to_js_obscure()
  inspect(react_element_has_prop(fieldset_node, "disabled"), content="true")
  inspect(react_element_bool_prop(fieldset_node, "disabled"), content="false")
  let output_node = output(name="result", html_for="first second", [Text("42")]).to_js_obscure()
  inspect(
    react_element_string_prop(output_node, "htmlFor"),
    content="first second",
  )
  let progress_node = progress(value=3.5, max=5.0, []).to_js_obscure()
  inspect(
    react_element_number_prop_matches(progress_node, "value", 3.5),
    content="true",
  )
  inspect(
    react_element_number_prop_matches(progress_node, "max", 5.0),
    content="true",
  )

  let dialog_node = dialog(
    open=false,
    on_cancel=fn(_) {  },
    on_close=fn(_) {  },
    [Text("Closed")],
  ).to_js_obscure()
  inspect(react_element_has_prop(dialog_node, "open"), content="true")
  inspect(react_element_bool_prop(dialog_node, "open"), content="false")
  inspect(
    react_element_has_function_prop(dialog_node, "onCancel"),
    content="true",
  )
  inspect(
    react_element_has_function_prop(dialog_node, "onClose"),
    content="true",
  )
  inspect(DOMEventType::Cancel.to_string(), content="cancel")
  inspect(DOMEventType::Close.to_string(), content="close")

  let meta_node = meta(http_equiv="content-language", content="en").to_js_obscure()
  inspect(react_element_tag(meta_node), content="meta")
  inspect(
    react_element_string_prop(meta_node, "httpEquiv"),
    content="content-language",
  )
  let semantic_node = time_(date_time="2026-08-31", [Text("Today")]).to_js_obscure()
  inspect(
    react_element_string_prop(semantic_node, "dateTime"),
    content="2026-08-31",
  )
}

///|
test "generated SVG helpers use React camel-case properties" {
  install_test_react()
  let svg_node = svg(
    view_box="0 0 24 24",
    width="24",
    height="24",
    aria_label="Status icon",
    [
      defs([
        linear_gradient(id="status-gradient", x1="0%", x2="100%", [
          stop(offset="0%", stop_color="#fff", []),
        ]),
      ]),
      path(
        d="M2 12h20",
        stroke="currentColor",
        stroke_width="2",
        path_length="20",
        [],
      ),
      use_(href="#shape", xlink_href="#legacy-shape", []),
    ],
  ).to_js_obscure()
  inspect(react_element_tag(svg_node), content="svg")
  inspect(react_element_string_prop(svg_node, "viewBox"), content="0 0 24 24")
  inspect(
    react_element_string_prop(svg_node, "aria-label"),
    content="Status icon",
  )
  let path_node = react_element_child(svg_node, 1)
  inspect(react_element_string_prop(path_node, "strokeWidth"), content="2")
  inspect(react_element_string_prop(path_node, "pathLength"), content="20")
  let use_node = react_element_child(svg_node, 2)
  inspect(
    react_element_string_prop(use_node, "xlinkHref"),
    content="#legacy-shape",
  )
}

///|
test "escape hatch preserves arbitrary aria data and custom-element attributes" {
  install_test_react()
  let attrs = ElementAttrs::new()
  attrs.set("aria-live", "polite")
  attrs.set("data-state", "ready")
  attrs.set("customvalue", "opaque")
  let node = create_element(
      "moonbit-widget",
      attrs,
      ElementEvents::new(),
      style=@css.respo_style(),
      [Text("Custom")],
    )
    .to_node()
    .to_js_obscure()
  inspect(react_element_tag(node), content="moonbit-widget")
  inspect(react_element_string_prop(node, "aria-live"), content="polite")
  inspect(react_element_string_prop(node, "data-state"), content="ready")
  inspect(react_element_string_prop(node, "customvalue"), content="opaque")
}

///|
test "form handlers receive DOM event values through React props" {
  install_test_react()
  let mut received_value = ""
  let node = input(on_change=fn(event) { received_value = event.target_value() }).to_js_obscure()
  react_element_trigger_event(node, "onChange", test_dom_event())
  inspect(received_value, content="updated value")
}

///|
test "DOMEvent exposes keyboard, pointer, modifier, and control APIs" {
  let event = test_dom_event()
  inspect(event.target_value(), content="updated value")
  inspect(event.target_checked(), content="true")
  inspect(event.key(), content="Enter")
  inspect(event.key_code(), content="13")
  inspect(event.client_x(), content="24")
  inspect(event.client_y(), content="48")
  inspect(event.ctrl_key(), content="true")
  inspect(event.shift_key(), content="true")
  inspect(event.alt_key(), content="true")
  inspect(event.meta_key(), content="true")
  event.prevent_default()
  event.stop_propagation()
  inspect(test_dom_event_default_prevented(event), content="true")
  inspect(test_dom_event_propagation_stopped(event), content="true")
}

///|
test "DOMEvent exposes checked dom-ffi native event views" {
  let pointer = test_dom_event()
  match pointer.native_pointer_event() {
    Some(native) => {
      inspect(native.pointer_id(), content="17")
      inspect(native.button(), content="1")
      inspect(native.buttons(), content="3")
      inspect(native.pressure(), content="0.5")
      inspect(native.client_x(), content="24.5")
      inspect(native.client_y(), content="48.5")
    }
    None => fail("expected a pointer native event")
  }
  inspect(
    match pointer.native_wheel_event() {
      None => true
      Some(_) => false
    },
    content="true",
  )

  let wheel = test_wheel_dom_event()
  match wheel.native_wheel_event() {
    Some(native) => {
      inspect(native.delta_x(), content="1.5")
      inspect(native.delta_y(), content="-2.5")
      inspect(native.delta_mode(), content="1")
    }
    None => fail("expected a wheel native event")
  }
  inspect(
    match wheel.native_pointer_event() {
      None => true
      Some(_) => false
    },
    content="true",
  )

  let generic = test_generic_dom_event()
  inspect(
    match generic.native_pointer_event() {
      None => true
      Some(_) => false
    },
    content="true",
  )
  inspect(
    match generic.native_wheel_event() {
      None => true
      Some(_) => false
    },
    content="true",
  )
}

///|
test "innerHTML uses React's required object prop" {
  install_test_react()
  let node = div(innerHTML="<strong>trusted</strong>", []).to_js_obscure()
  inspect(react_element_inner_html(node), content="<strong>trusted</strong>")
}

///|
test "invalid innerHTML and form prop combinations are rejected" {
  install_test_react()
  inspect(
    test_callback_throws(fn() {
      let _ = div(innerHTML="<strong>trusted</strong>", [
        Text("conflicting child"),
      ]).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(value="controlled", default_value="initial").to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(checked=true, default_checked=false, on_change=fn(_) {  }).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = textarea(value="controlled", default_value="initial").to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = select(value="controlled", default_value="initial", []).to_js_obscure()
    }),
    content="true",
  )
  let selected_attrs = ElementAttrs::new()
  selected_attrs.set_bool("selected", true)
  inspect(
    test_callback_throws(fn() {
      let _ = option(attrs=selected_attrs, [Text("unsupported")]).to_js_obscure()
    }),
    content="true",
  )
}

///|
test "uncontrolled form defaults preserve strings and false booleans" {
  install_test_react()
  let input_node = input(default_value="initial", default_checked=false).to_js_obscure()
  inspect(
    react_element_string_prop(input_node, "defaultValue"),
    content="initial",
  )
  inspect(react_element_has_prop(input_node, "defaultChecked"), content="true")
  inspect(
    react_element_bool_prop(input_node, "defaultChecked"),
    content="false",
  )
  let textarea_node = textarea(default_value="draft").to_js_obscure()
  inspect(
    react_element_string_prop(textarea_node, "defaultValue"),
    content="draft",
  )
  let select_node = select(default_value="second", []).to_js_obscure()
  inspect(
    react_element_string_prop(select_node, "defaultValue"),
    content="second",
  )
}

///|
test "controlled forms require change handling or explicit read-only state" {
  install_test_react()
  inspect(
    test_callback_throws(fn() { let _ = input(value="locked").to_js_obscure() }),
    content="true",
  )
  let readonly_input = input(value="locked", read_only=true).to_js_obscure()
  inspect(react_element_bool_prop(readonly_input, "readOnly"), content="true")
  let controlled_textarea = textarea(value="editable", on_change=fn(_) {  }).to_js_obscure()
  inspect(
    react_element_has_function_prop(controlled_textarea, "onChange"),
    content="true",
  )
  let readonly_textarea = textarea(value="locked", read_only=true).to_js_obscure()
  inspect(
    react_element_bool_prop(readonly_textarea, "readOnly"),
    content="true",
  )
  let legacy_readonly_attrs = ElementAttrs::new()
  legacy_readonly_attrs.set("value", "locked")
  legacy_readonly_attrs.set("readOnly", "true")
  inspect(
    test_callback_throws(fn() {
      let _ = input(attrs=legacy_readonly_attrs).to_js_obscure()
    }),
    content="false",
  )
  let checkbox_value = input(type_=Checkbox, value="submitted-value").to_js_obscure()
  inspect(
    react_element_string_prop(checkbox_value, "value"),
    content="submitted-value",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(type_=File, value="forbidden").to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = select(value="first", [option(value="first", [Text("First")])]).to_js_obscure()
    }),
    content="true",
  )
}

///|
test "multiple selects require array values" {
  install_test_react()
  inspect(
    test_callback_throws(fn() {
      let _ = select(value="first", multiple=true, []).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = select(values=["first"], []).to_js_obscure()
    }),
    content="true",
  )
  let manual_multiple_value = ElementAttrs::new()
  manual_multiple_value.set_bool("multiple", true)
  manual_multiple_value.set("value", "first")
  inspect(
    test_callback_throws(fn() {
      let _ = create_element(
          "select",
          manual_multiple_value,
          ElementEvents::new(),
          style=@css.respo_style(),
          [],
        )
        .to_node()
        .to_js_obscure()
    }),
    content="true",
  )
  let manual_multiple_default = ElementAttrs::new()
  manual_multiple_default.set_bool("multiple", true)
  manual_multiple_default.set("defaultValue", "first")
  inspect(
    test_callback_throws(fn() {
      let _ = create_element(
          "select",
          manual_multiple_default,
          ElementEvents::new(),
          style=@css.respo_style(),
          [],
        )
        .to_node()
        .to_js_obscure()
    }),
    content="true",
  )
  let manual_single_value = ElementAttrs::new()
  manual_single_value.set_js_value(
    "value",
    @dom.JsObscure::from_array([@dom.JsObscure::from_string("first")]),
  )
  inspect(
    test_callback_throws(fn() {
      let _ = create_element(
          "select",
          manual_single_value,
          ElementEvents::new(),
          style=@css.respo_style(),
          [],
        )
        .to_node()
        .to_js_obscure()
    }),
    content="true",
  )
  let controlled = select(
    values=["first", "second"],
    multiple=true,
    on_change=fn(_) {  },
    [],
  ).to_js_obscure()
  inspect(
    react_element_string_array_prop(controlled, "value"),
    content="first|second",
  )
  let uncontrolled = select(default_values=["second"], multiple=true, []).to_js_obscure()
  inspect(
    react_element_string_array_prop(uncontrolled, "defaultValue"),
    content="second",
  )
  inspect(react_element_string_array_prop(uncontrolled, "value"), content="")
}

///|
test "form Actions preserve typed payloads and valid submit controls" {
  install_test_react()
  let data = test_form_data()
  inspect(data.get_string("field") == Some("value"), content="true")
  inspect(data.get_string("missing") is None, content="true")
  inspect(data.get_string("attachment") is None, content="true")
  inspect(
    match data.to_dom_form_data().get("attachment") {
      Some(@dom.FormDataValue::File(file)) => file.name() == "fixture.txt"
      _ => false
    },
    content="true",
  )
  let action = form_action(fn(_data) {  })
  let form_node = form(
    id="action-form",
    class_name="action",
    class_list=["pending"],
    action~,
    method_="post",
    on_submit=fn(_) {  },
    [
      input(type_=InputType::Submit, name="intent", form_action=action),
      button(
        button_type="submit",
        name="intent",
        value="save",
        form_action=action,
        [Text("Save")],
      ),
    ],
  ).to_js_obscure()
  inspect(react_element_has_function_prop(form_node, "action"), content="true")
  inspect(
    react_element_string_prop(form_node, "className"),
    content="action pending",
  )
  inspect(react_element_string_prop(form_node, "method"), content="post")
  inspect(
    react_element_has_function_prop(form_node, "onSubmit"),
    content="true",
  )
  let submit_input = input(
    type_=InputType::Submit,
    name="intent",
    form_action=action,
  ).to_js_obscure()
  inspect(
    react_element_has_function_prop(submit_input, "formAction"),
    content="true",
  )
  let submit_button = button(
    button_type="submit",
    name="intent",
    value="save",
    form_action=action,
    [Text("Save")],
  ).to_js_obscure()
  inspect(
    react_element_has_function_prop(submit_button, "formAction"),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = input(type_=InputType::Text, form_action=action).to_js_obscure()
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = button(button_type="button", form_action=action, [Text("Invalid")]).to_js_obscure()
    }),
    content="true",
  )
  let async_node = form(
    action=async_form_action(async fn(_data) {
      test_resolved_unit_promise().wait()
    }),
    [],
  ).to_js_obscure()
  inspect(
    react_element_function_prop_returns_promise(async_node, "action", data),
    content="true",
  )
}

///|
test "element helpers preserve form, link, and media props" {
  install_test_react()

  let label_node = label(for_="email", []).to_js_obscure()
  inspect(react_element_tag(label_node), content="label")
  inspect(react_element_string_prop(label_node, "htmlFor"), content="email")

  let input_node = input(
    id="terms",
    class_name="field",
    class_list=["controlled"],
    type_=Checkbox,
    value="accepted",
    placeholder="accept terms",
    disabled=true,
    checked=false,
    on_click=fn(_event) {  },
    on_input=fn(_event) {  },
  ).to_js_obscure()
  inspect(react_element_tag(input_node), content="input")
  inspect(react_element_string_prop(input_node, "id"), content="terms")
  inspect(
    react_element_string_prop(input_node, "className"),
    content="field controlled",
  )
  inspect(react_element_string_prop(input_node, "type"), content="checkbox")
  inspect(react_element_bool_prop(input_node, "disabled"), content="true")
  inspect(react_element_has_prop(input_node, "checked"), content="true")
  inspect(react_element_bool_prop(input_node, "checked"), content="false")
  inspect(
    react_element_has_function_prop(input_node, "onClick"),
    content="true",
  )
  inspect(
    react_element_has_function_prop(input_node, "onInput"),
    content="true",
  )

  let button_node = button(
    id="submit",
    class_name="action",
    class_list=["primary"],
    innerHTML="<b>Submit</b>",
    button_type="submit",
    disabled=true,
    on_click=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(button_node, "id"), content="submit")
  inspect(
    react_element_string_prop(button_node, "className"),
    content="action primary",
  )
  inspect(react_element_inner_html(button_node), content="<b>Submit</b>")
  inspect(react_element_string_prop(button_node, "type"), content="submit")
  inspect(react_element_bool_prop(button_node, "disabled"), content="true")
  inspect(
    react_element_has_function_prop(button_node, "onClick"),
    content="true",
  )

  let link_node = a(href="/docs", target="_blank", [Text("docs")]).to_js_obscure()
  inspect(react_element_tag(link_node), content="a")
  inspect(react_element_string_prop(link_node, "href"), content="/docs")
  inspect(react_element_string_prop(link_node, "target"), content="_blank")

  let media_node = video(
    id="video",
    class_name="media",
    class_list=["wide"],
    src="movie.mp4",
    controls=true,
    autoplay=true,
    loop_enabled=true,
    muted=true,
    width="640",
    height="360",
    on_click=fn(_event) {  },
    on_play=fn(_event) {  },
    on_pause=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_tag(media_node), content="video")
  inspect(react_element_string_prop(media_node, "id"), content="video")
  inspect(
    react_element_string_prop(media_node, "className"),
    content="media wide",
  )
  inspect(react_element_bool_prop(media_node, "controls"), content="true")
  inspect(react_element_bool_prop(media_node, "autoPlay"), content="true")
  inspect(react_element_bool_prop(media_node, "loop"), content="true")
  inspect(react_element_bool_prop(media_node, "muted"), content="true")
  inspect(react_element_string_prop(media_node, "width"), content="640")
  inspect(react_element_string_prop(media_node, "height"), content="360")
  inspect(
    react_element_has_function_prop(media_node, "onClick"),
    content="true",
  )
  inspect(react_element_has_function_prop(media_node, "onPlay"), content="true")
  inspect(
    react_element_has_function_prop(media_node, "onPause"),
    content="true",
  )

  let audio_node = audio(
    id="audio",
    class_name="media",
    class_list=["sound"],
    src="sound.mp3",
    controls=true,
    autoplay=true,
    loop_enabled=true,
    muted=true,
    on_play=fn(_event) {  },
    on_pause=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_tag(audio_node), content="audio")
  inspect(react_element_string_prop(audio_node, "id"), content="audio")
  inspect(
    react_element_string_prop(audio_node, "className"),
    content="media sound",
  )
  inspect(react_element_bool_prop(audio_node, "controls"), content="true")
  inspect(react_element_bool_prop(audio_node, "autoPlay"), content="true")
  inspect(react_element_bool_prop(audio_node, "loop"), content="true")
  inspect(react_element_bool_prop(audio_node, "muted"), content="true")
  inspect(react_element_has_function_prop(audio_node, "onPlay"), content="true")
  inspect(
    react_element_has_function_prop(audio_node, "onPause"),
    content="true",
  )

  let select_node = select(
    id="choices",
    class_name="field",
    class_list=["multiple"],
    values=["second"],
    disabled=true,
    multiple=true,
    on_change=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(select_node, "id"), content="choices")
  inspect(
    react_element_string_prop(select_node, "className"),
    content="field multiple",
  )
  inspect(
    react_element_string_array_prop(select_node, "value"),
    content="second",
  )
  inspect(react_element_bool_prop(select_node, "disabled"), content="true")
  inspect(react_element_bool_prop(select_node, "multiple"), content="true")
  inspect(
    react_element_has_function_prop(select_node, "onChange"),
    content="true",
  )

  let option_node = option(
    id="second",
    class_name="choice",
    class_list=["selected"],
    innerHTML="<i>Second</i>",
    value="second",
    disabled=true,
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(option_node, "id"), content="second")
  inspect(
    react_element_string_prop(option_node, "className"),
    content="choice selected",
  )
  inspect(react_element_inner_html(option_node), content="<i>Second</i>")
  inspect(react_element_string_prop(option_node, "value"), content="second")
  inspect(react_element_bool_prop(option_node, "disabled"), content="true")

  let textarea_node = textarea(
    id="notes",
    class_name="field",
    class_list=["large"],
    value="hello",
    placeholder="notes",
    rows=3,
    cols=20,
    disabled=true,
    on_change=fn(_event) {  },
    on_input=fn(_event) {  },
  ).to_js_obscure()
  inspect(react_element_string_prop(textarea_node, "id"), content="notes")
  inspect(
    react_element_string_prop(textarea_node, "className"),
    content="field large",
  )
  inspect(react_element_string_prop(textarea_node, "value"), content="hello")
  inspect(
    react_element_string_prop(textarea_node, "placeholder"),
    content="notes",
  )
  inspect(react_element_int_prop(textarea_node, "rows"), content="3")
  inspect(react_element_int_prop(textarea_node, "cols"), content="20")
  inspect(react_element_bool_prop(textarea_node, "disabled"), content="true")
  inspect(
    react_element_has_function_prop(textarea_node, "onChange"),
    content="true",
  )
  inspect(
    react_element_has_function_prop(textarea_node, "onInput"),
    content="true",
  )

  let image_node = img(
    id="logo",
    class_name="image",
    class_list=["responsive"],
    src="logo.svg",
    alt="Logo",
    width="120",
    height="40",
    on_click=fn(_event) {  },
    on_load=fn(_event) {  },
    on_error=fn(_event) {  },
  ).to_js_obscure()
  inspect(react_element_string_prop(image_node, "id"), content="logo")
  inspect(
    react_element_string_prop(image_node, "className"),
    content="image responsive",
  )
  inspect(react_element_string_prop(image_node, "src"), content="logo.svg")
  inspect(react_element_string_prop(image_node, "alt"), content="Logo")
  inspect(react_element_string_prop(image_node, "width"), content="120")
  inspect(react_element_string_prop(image_node, "height"), content="40")
  inspect(
    react_element_has_function_prop(image_node, "onClick"),
    content="true",
  )
  inspect(react_element_has_function_prop(image_node, "onLoad"), content="true")
  inspect(
    react_element_has_function_prop(image_node, "onError"),
    content="true",
  )
}

///|
test "text element helpers combine classes and handlers" {
  install_test_react()
  let node = span(
    id="notice",
    class_name="base",
    class_list=["expanded", "active"],
    innerHTML="<em>trusted</em>",
    on_click=fn(_event) {  },
    [],
  ).to_js_obscure()
  inspect(react_element_string_prop(node, "id"), content="notice")
  inspect(
    react_element_string_prop(node, "className"),
    content="base expanded active",
  )
  inspect(react_element_inner_html(node), content="<em>trusted</em>")
  inspect(react_element_has_function_prop(node, "onClick"), content="true")
}

///|
test "render reuses the React root for a parent element" {
  install_test_react_dom()
  let parent = test_parent_element()
  render(Text("first"), parent)
  render(Text("second"), parent)
  inspect(react_render_create_root_count(), content="1")
  inspect(react_render_call_count(), content="2")
}

///|
test "unmount releases the React root for a parent element" {
  install_test_react_dom()
  let parent = test_parent_element()
  render(Text("first"), parent)
  unmount(parent)
  render(Text("second"), parent)
  inspect(react_render_create_root_count(), content="2")
  inspect(react_unmount_call_count(), content="1")
}

///|
test "root options map React 19 identifiers and error callbacks" {
  install_test_react_dom()
  let options = RootOptions::new(
    identifier_prefix="moonbit-",
    on_caught_error=fn(_, _) {  },
    on_uncaught_error=fn(_, _) {  },
    on_recoverable_error=fn(_, _) {  },
  )
  render_with_options(Text("configured"), test_parent_element(), options)
  inspect(test_create_root_identifier_prefix(), content="moonbit-")
  inspect(test_create_root_callback_count(), content="3")
  inspect(test_react_error().message(), content="root failed")
  inspect(
    test_react_error_info().component_stack(),
    content="\n    at MoonBitProbe",
  )
}

///|
test "hydrate_root registers a reusable root with matching options" {
  install_test_react_dom()
  let parent = test_parent_element()
  hydrate_root(
    Text("hydrated"),
    parent,
    options=RootOptions::new(identifier_prefix="ssr-"),
  )
  render(Text("updated"), parent)
  inspect(react_hydrate_root_call_count(), content="1")
  inspect(react_render_create_root_count(), content="0")
  inspect(react_render_call_count(), content="1")
  inspect(test_hydrate_root_identifier_prefix(), content="ssr-")
}

///|
test "portal and synchronous server renderer preserve their arguments" {
  install_test_react_dom()
  let portal = create_portal(
    Text("inside portal"),
    test_parent_element(),
    key="modal",
  )
  inspect(portal is JsNode(_), content="true")
  inspect(test_portal_child(), content="inside portal")
  inspect(test_portal_key(), content="modal")
  inspect(
    render_to_string(Text("server"), identifier_prefix="ssr-"),
    content="<main>ssr-</main>",
  )
  inspect(test_server_render_prefix(), content="ssr-")
}

///|
test "React DOM operational APIs map callbacks and all six resource hints" {
  install_test_react_dom()
  inspect(
    test_callback_throws(fn() {
      let _ = PreloadOptions::new(PreloadDestination::Fetch)
    }),
    content="true",
  )
  inspect(
    test_callback_throws(fn() {
      let _ = PreloadOptions::new(
        PreloadDestination::Fetch,
        cross_origin=ResourceCrossOrigin::Anonymous,
      )
    }),
    content="false",
  )
  let mut callback_calls = 0
  flush_sync(fn() { callback_calls = callback_calls + 1 })
  prefetch_dns("https://dns.example")
  preconnect(
    "https://connect.example",
    cross_origin=ResourceCrossOrigin::Anonymous,
  )
  preload(
    "/hero.png",
    PreloadOptions::new(
      PreloadDestination::Image,
      cross_origin=ResourceCrossOrigin::UseCredentials,
      referrer_policy=ResourceReferrerPolicy::OriginWhenCrossOrigin,
      integrity="sha256-image",
      mime_type="image/png",
      nonce="preload-nonce",
      fetch_priority=ResourceFetchPriority::High,
      image_src_set="/hero.png 1x, /hero@2x.png 2x",
      image_sizes="100vw",
    ),
  )
  preload_module(
    "/module.js",
    options=ModuleHintOptions::new(
      cross_origin=ResourceCrossOrigin::Anonymous,
      integrity="sha256-module",
      nonce="module-nonce",
    ),
  )
  preinit(
    "/classic.js",
    PreinitOptions::script(fetch_priority=ResourceFetchPriority::Low),
  )
  preinit(
    "/style.css",
    PreinitOptions::style(ResourceStylePrecedence::High, nonce="style-nonce"),
  )
  preinit_module("/entry.js")

  inspect(callback_calls, content="1")
  inspect(test_flush_sync_count(), content="1")
  inspect(test_dom_operation_count("prefetchDNS"), content="1")
  inspect(test_dom_operation_count("preconnect"), content="1")
  inspect(test_dom_operation_count("preload"), content="1")
  inspect(test_dom_operation_count("preloadModule"), content="1")
  inspect(test_dom_operation_count("preinit"), content="2")
  inspect(test_dom_operation_count("preinitModule"), content="1")
  inspect(
    test_dom_operation_href("preconnect", 0),
    content="https://connect.example",
  )
  inspect(
    test_dom_operation_option("preconnect", 0, "crossOrigin"),
    content="anonymous",
  )
  inspect(test_dom_operation_option("preload", 0, "as"), content="image")
  inspect(
    test_dom_operation_option("preload", 0, "crossOrigin"),
    content="use-credentials",
  )
  inspect(
    test_dom_operation_option("preload", 0, "referrerPolicy"),
    content="origin-when-cross-origin",
  )
  inspect(
    test_dom_operation_option("preload", 0, "fetchPriority"),
    content="high",
  )
  inspect(
    test_dom_operation_option("preload", 0, "imageSrcSet"),
    content="/hero.png 1x, /hero@2x.png 2x",
  )
  inspect(test_dom_operation_option("preloadModule", 0, "as"), content="script")
  inspect(
    test_dom_operation_option("preloadModule", 0, "integrity"),
    content="sha256-module",
  )
  inspect(test_dom_operation_option("preinit", 0, "as"), content="script")
  inspect(
    test_dom_operation_option("preinit", 0, "fetchPriority"),
    content="low",
  )
  inspect(test_dom_operation_option("preinit", 1, "as"), content="style")
  inspect(test_dom_operation_option("preinit", 1, "precedence"), content="high")
  inspect(test_dom_operation_option("preinitModule", 0, "as"), content="script")
}

///|
async test "Web Stream renderer maps options, allReady, text, and abort" {
  install_test_react()
  install_test_react_dom()
  install_test_stream_renderer()
  let mut error_reports = 0
  let stream = render_to_readable_stream(
    Text("server"),
    options=StreamRenderOptions::new(
      identifier_prefix="stream-",
      bootstrap_scripts=["/client.js"],
      bootstrap_modules=["/module.js"],
      nonce="nonce-value",
      on_error=fn(error) {
        if error.message() == "reported stream error" {
          error_reports = error_reports + 1
        }
      },
    ),
  )
  inspect(test_stream_identifier_prefix(), content="stream-")
  inspect(test_stream_bootstrap_script_count(), content="1")
  inspect(test_stream_bootstrap_module_count(), content="1")
  inspect(test_stream_nonce(), content="nonce-value")
  inspect(error_reports, content="1")
  inspect(
    test_is_readable_stream(stream.to_js_readable_stream()),
    content="true",
  )
  stream.wait_all_ready()
  inspect(stream.read_text(), content="streamed:server")
  stream.abort(reason="test complete")
  inspect(test_stream_abort_count(), content="1")
}

///|
test "root integration defaults omit optional React arguments" {
  install_test_react_dom()
  render_with_options(
    Text("default options"),
    test_parent_element(),
    RootOptions::new(),
  )
  inspect(test_create_root_identifier_prefix(), content="")
  inspect(test_create_root_callback_count(), content="0")
  hydrate_root(Text("hydrated"), test_parent_element())
  inspect(react_hydrate_root_call_count(), content="1")
  let _ = create_portal(Text("unkeyed"), test_parent_element())
  inspect(test_portal_key(), content="")
  inspect(render_to_string(Text("server")), content="<main>none</main>")
  inspect(test_server_render_prefix(), content="")
}

///|
test "hook wrappers preserve MoonBit values and callbacks" {
  install_test_react_hooks()
  let (value, set_value) = use_state(1)
  inspect(value, content="1")
  set_value(2)
  inspect(hook_test_state(), content="2")

  let (updatable, update_value) = use_state_with_updater(3)
  inspect(updatable, content="3")
  update_value(StateUpdate::Set(4))
  inspect(hook_test_state(), content="4")
  update_value(StateUpdate::Update(fn(current) { current + 5 }))
  inspect(hook_test_state(), content="9")

  let memoized = use_memo_deps(fn() { 41 }, [])
  inspect(memoized, content="41")
  let callback = use_callback_deps(fn(value : Int) { value + 1 }, [])
  inspect(callback(4), content="5")
  let effect_event = use_effect_event(fn(value : Int) { value + 2 })
  inspect(effect_event(4), content="6")
  let mut callback0_calls = 0
  let callback0 = use_callback0_deps(
    fn() { callback0_calls = callback0_calls + 1 },
    [],
  )
  callback0()
  inspect(callback0_calls, content="1")

  let react_ref = use_ref("first")
  inspect(react_ref.get(), content="first")
  react_ref.set("second")
  inspect(react_ref.get(), content="second")

  let attrs = ElementAttrs::new()
  attrs.set_js_value("ref", react_ref.to_js_obscure())
  let ref_node = create_element(
      "input",
      attrs,
      ElementEvents::new(),
      style=@css.respo_style(),
      [],
    )
    .to_node()
    .to_js_obscure()
  inspect(
    react_element_prop_equals(ref_node, "ref", react_ref.to_js_obscure()),
    content="true",
  )

  let dom_ref = use_dom_ref()
  inspect(
    match dom_ref.current() {
      None => true
      Some(_) => false
    },
    content="true",
  )
  set_test_dom_ref(dom_ref.to_js_obscure(), true)
  inspect(
    match dom_ref.current() {
      Some(element) => element.tag_name() == "INPUT"
      None => false
    },
    content="true",
  )
  set_test_dom_ref(dom_ref.to_js_obscure(), false)
  inspect(
    match dom_ref.current() {
      None => true
      Some(_) => false
    },
    content="true",
  )

  let (reduced, dispatch) = use_reducer(initial=3, fn(
    state : Int,
    action : Int,
  ) {
    state + action
  })
  inspect(reduced, content="3")
  dispatch(4)
  inspect(hook_test_reduced_state(), content="7")

  let (non_default_state, dispatch_non_default) = use_reducer_with_initial(
    NonDefaultReducerState::Initial,
    fn(_state : NonDefaultReducerState, _action : Unit) {
      NonDefaultReducerState::Updated
    },
  )
  inspect(non_default_state == NonDefaultReducerState::Initial, content="true")
  dispatch_non_default(())

  let (action_state, dispatch_action, is_action_pending) = use_action_state(
    10,
    fn(state : Int, value : Int) { state + value },
  )
  inspect(action_state, content="10")
  inspect(is_action_pending, content="false")
  dispatch_action(5)
  inspect(hook_test_reduced_state(), content="15")

  let (optimistic_state, dispatch_optimistic) = use_optimistic(10, fn(
    state : Int,
    value : Int,
  ) {
    state + value
  })
  inspect(optimistic_state, content="10")
  dispatch_optimistic(5)
  inspect(hook_test_optimistic_state(), content="15")

  let (async_action_state, dispatch_async_action, is_async_action_pending) = use_async_action_state(
    20,
    async fn(state : Int, value : Int) {
      test_resolved_int_promise(state + value).wait()
    },
  )
  inspect(async_action_state, content="20")
  inspect(is_async_action_pending, content="false")
  dispatch_async_action(5)
  inspect(hook_test_reduced_is_promise(), content="true")

  let form_status = use_form_status()
  inspect(form_status.pending(), content="true")
  inspect(form_status.submission_method(), content="post")
  inspect(
    match form_status.data() {
      Some(data) => data.get_string("field") == Some("submitted")
      None => false
    },
    content="true",
  )
  inspect(form_status.action() is Some(_), content="true")
  set_test_form_status_action_present(false)
  inspect(form_status.action() is None, content="true")

  let mut subscribes = 0
  let mut unsubscribes = 0
  let external_snapshot = use_sync_external_store(
    fn(_notify) {
      subscribes = subscribes + 1
      fn() { unsubscribes = unsubscribes + 1 }
    },
    fn() { 7 },
    get_server_snapshot=fn() { 6 },
  )
  inspect(external_snapshot, content="7")
  inspect(subscribes, content="1")
  inspect(unsubscribes, content="1")
  inspect(hook_test_external_server_snapshot(), content="6")
  inspect(
    use_sync_external_store(fn(_notify) { fn() {  } }, fn() { 8 }),
    content="8",
  )

  let imperative_ref : ImperativeRef[Int] = use_imperative_ref()
  inspect(imperative_ref.current() is None, content="true")
  use_imperative_handle_deps(imperative_ref, fn() { 42 }, [
    obscure("first"),
    obscure("second"),
  ])
  inspect(imperative_ref.current() == Some(42), content="true")
  inspect(hook_test_imperative_dep_count(), content="2")
}

///|
test "concurrent hook wrappers preserve values and run transitions" {
  install_test_react_hooks()
  inspect(use_id(), content="moonbit-test-id")
  inspect(use_deferred_value("deferred"), content="deferred")

  let (is_pending, start) = use_transition()
  inspect(is_pending, content="false")
  let mut transition_effects = 0
  start(fn() { transition_effects = transition_effects + 1 })
  start_transition(fn() { transition_effects = transition_effects + 1 })
  inspect(transition_effects, content="2")
  inspect(hook_test_transition_action_count(), content="2")
}

///|
test "effect wrappers invoke effects and cleanup functions" {
  install_test_react_hooks()
  let mut effects = 0
  let mut cleanups = 0
  use_effect_once(fn() { effects = effects + 1 })
  use_effect_deps(fn() { effects = effects + 1 }, [])
  use_layout_effect_deps(fn() { effects = effects + 1 }, [])
  use_effect_once_with_cleanup(fn() {
    effects = effects + 1
    fn() { cleanups = cleanups + 1 }
  })
  use_layout_effect_cleanup_deps(
    fn() {
      effects = effects + 1
      fn() { cleanups = cleanups + 1 }
    },
    [],
  )
  inspect(effects, content="5")
  inspect(cleanups, content="2")
}

///|
test "components without child access render through their React factory" {
  install_test_react()
  let node = component(
    fn(_props : String) { div([Text("component body")]) },
    "props",
    [Text("React receives this child")],
  ).to_js_obscure()
  inspect(react_element_tag(node), content="div")
  inspect(react_element_child_count(node), content="1")
}

///|
test "typed component types preserve props across memo lazy and JS bridges" {
  install_component_api_test_react()
  let props = ComponentApiProps::{ label: "typed value" }
  let defined = define_component(comp_component_api_test)
  let defined_node = defined.render(props).to_js_obscure()
  let rendered = render_test_component_factory(defined_node)
  inspect(react_element_first_child_string(rendered), content="typed value")

  let custom_memo = defined.memo(are_props_equal=fn(previous, next) {
    previous.label == next.label
  })
  let custom_memo_node = custom_memo.render(props).to_js_obscure()
  inspect(test_component_kind(custom_memo_node), content="memo")
  inspect(test_memo_has_custom_compare(custom_memo_node), content="true")
  inspect(
    test_memo_compare(
      custom_memo_node,
      @dom.v_to_js_obscure(ComponentApiProps::{ label: "same" }),
      @dom.v_to_js_obscure(ComponentApiProps::{ label: "same" }),
    ),
    content="true",
  )
  inspect(
    test_memo_compare(
      custom_memo_node,
      @dom.v_to_js_obscure(ComponentApiProps::{ label: "before" }),
      @dom.v_to_js_obscure(ComponentApiProps::{ label: "after" }),
    ),
    content="false",
  )
  let default_memo = defined.memo()
  inspect(
    test_memo_has_custom_compare(default_memo.render(props).to_js_obscure()),
    content="false",
  )

  let lazy_component_value : ReactComponent[ComponentApiProps] = lazy_component(async fn() {
      test_resolved_unit_promise().wait()
      define_component(comp_component_api_test)
    },
  )
  inspect(
    test_component_kind(lazy_component_value.render(props).to_js_obscure()),
    content="lazy",
  )
  inspect(
    test_lazy_loader_returns_promise(
      lazy_component_value.render(props).to_js_obscure(),
    ),
    content="true",
  )

  let js_component : ReactComponent[ComponentApiProps] = component_from_js(
    test_js_component(),
  )
  let js_rendered = render_test_component_factory(
    js_component.render(props).to_js_obscure(),
  )
  inspect(test_js_component_received_label(js_rendered), content="typed value")
  inspect(js_component.to_js_obscure().is_nil(), content="false")

  let boundary = suspense(Text("loading"), [Text("ready")]).to_js_obscure()
  inspect(test_suspense_tag_matches(boundary), content="true")
  inspect(react_element_string_prop(boundary, "fallback"), content="loading")
}

///|
test "Activity exposes both React 19.2 modes and preserves children" {
  install_component_api_test_react()
  let visible = activity(ActivityMode::Visible, [Text("ready")]).to_js_obscure()
  inspect(ActivityMode::Visible.to_string(), content="visible")
  inspect(test_activity_tag_matches(visible), content="true")
  inspect(react_element_string_prop(visible, "mode"), content="visible")
  inspect(react_element_child_count(visible), content="1")
  let hidden = activity(ActivityMode::Hidden, [Text("waiting")]).to_js_obscure()
  inspect(ActivityMode::Hidden.to_string(), content="hidden")
  inspect(test_activity_tag_matches(hidden), content="true")
  inspect(react_element_string_prop(hidden, "mode"), content="hidden")
  inspect(react_element_child_count(hidden), content="1")
}

///|
test "resources preserve cached identity and error boundaries map retry props" {
  install_component_api_test_react()
  let fulfilled_promise = test_resource_promise("fulfilled", "ready")
  let pending_promise = test_resource_promise("pending", "waiting")
  let rejected_promise = test_resource_promise("rejected", "failed")
  let fulfilled = resource_from_promise(fulfilled_promise)
  let pending = resource_from_promise(pending_promise)
  let rejected = resource_from_promise(rejected_promise)
  inspect(test_resource_state(fulfilled.to_js_obscure()), content="fulfilled")
  inspect(test_resource_state(pending.to_js_obscure()), content="pending")
  inspect(test_resource_state(rejected.to_js_obscure()), content="rejected")
  inspect(
    test_resource_identity(fulfilled.to_js_obscure(), fulfilled_promise),
    content="true",
  )
  inspect(use_resource(fulfilled), content="ready")
  let async_resource = resource_from_async(async fn() {
    test_resolved_unit_promise().wait()
    "async ready"
  })
  inspect(
    test_resource_is_thenable(async_resource.to_js_obscure()),
    content="true",
  )

  let boundary = error_boundary(
    fn(error) { p([Text("fallback: \{error.message()}")]) },
    [Text("child")],
    reset_key="retry-1",
    on_error=fn(_error, _info) {  },
  ).to_js_obscure()
  inspect(test_error_boundary_tag_matches(boundary), content="true")
  inspect(test_error_boundary_reset_key(boundary), content="retry-1")
  inspect(test_error_boundary_has_on_error(boundary), content="true")
  inspect(react_element_child_count(boundary), content="1")
  inspect(
    react_element_first_child_string(
      test_error_boundary_fallback(boundary, "broken"),
    ),
    content="fallback: broken",
  )
}

///|
struct StableComponentProps {
  label : String
}

///|
fn comp_stable_factory(props : StableComponentProps) -> VirtualNode {
  div([Text(props.label)])
}

///|
fn comp_stable_children_factory(
  _props : StableComponentProps,
  children : Array[VirtualNode],
) -> VirtualNode {
  create_element(
    "section",
    ElementAttrs::new(),
    ElementEvents::new(),
    style=@css.respo_style(),
    children,
  ).to_node()
}

///|
test "component factories keep identity across repeated renders" {
  install_component_identity_test_react()
  let first = component(comp_stable_factory, { label: "first" }, [])
  let second = component(comp_stable_factory, { label: "second" }, [])
  inspect(
    react_elements_have_same_tag(first.to_js_obscure(), second.to_js_obscure()),
    content="true",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(first.to_js_obscure()),
    ),
    content="first",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(second.to_js_obscure()),
    ),
    content="second",
  )

  let first_children = component_with_children(
    comp_stable_children_factory,
    { label: "ignored" },
    [Text("first child")],
  )
  let second_children = component_with_children(
    comp_stable_children_factory,
    { label: "ignored" },
    [Text("second child")],
  )
  inspect(
    react_elements_have_same_tag(
      first_children.to_js_obscure(),
      second_children.to_js_obscure(),
    ),
    content="true",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(first_children.to_js_obscure()),
    ),
    content="first child",
  )
  inspect(
    react_element_first_child_string(
      render_test_component_factory(second_children.to_js_obscure()),
    ),
    content="second child",
  )
}

///|
test "components can render their supplied MoonBit children" {
  install_test_react()
  let node = component_with_children(
    fn(_props : String, children) {
      create_element(
        "section",
        ElementAttrs::new(),
        ElementEvents::new(),
        style=@css.respo_style(),
        children,
      ).to_node()
    },
    "test",
    [Text("visible child")],
  )
  inspect(react_element_child_count(node.to_js_obscure()), content="1")
}
