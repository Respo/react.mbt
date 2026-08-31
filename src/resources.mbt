///|
/// A typed, identity-stable Promise resource for React 19 `use`.
///
/// Create resources outside render paths and reuse the same value across
/// retries. Recreating a Promise during render causes repeated suspension and a
/// React uncached-Promise warning.
struct ReactResource[T] {
  js_value : @dom.JsObscure
  _value_marker : T?
}

///|
/// Wraps an existing JavaScript Promise without changing its identity.
pub fn[T] resource_from_promise(
  promise : @js_async.Promise[T],
) -> ReactResource[T] {
  ReactResource::{
    js_value: @dom.v_to_js_obscure(promise),
    _value_marker: None,
  }
}

///|
/// Starts one MoonBit async operation and wraps its exported JavaScript Promise.
/// Call this outside component render paths so the resource identity is cached.
pub fn[T] resource_from_async(loader : async () -> T) -> ReactResource[T] {
  resource_from_promise(@js_async.Promise::from_async(loader))
}

///|
/// Returns the cached JavaScript Promise for explicit interoperation.
pub fn[T] ReactResource::to_js_obscure(
  self : ReactResource[T],
) -> @dom.JsObscure {
  self.js_value
}

///|
extern "js" fn react_use_resource(resource : @dom.JsObscure) -> @dom.JsObscure =
  #| (resource) => globalThis.React.use(resource)

///|
/// Reads a cached resource with React 19 `use`.
///
/// Unlike ordinary Hooks, React permits this call inside conditions and loops,
/// but it must still run while rendering a component. A pending resource
/// suspends to the nearest `suspense`; a rejected resource throws to the nearest
/// `error_boundary`.
pub fn[T] use_resource(resource : ReactResource[T]) -> T {
  react_use_resource(resource.js_value) |> @dom.js_obscure_to_v
}

///|
extern "js" fn react_error_boundary(
  fallback : @dom.JsObscure,
  on_error : @dom.JsObscure,
  reset_key : @dom.JsObscure,
  children : FixedArray[@dom.JsObscure],
) -> @dom.JsObscure =
  #| (fallback, onError, resetKey, children) => {
  #|   const Boundary = globalThis.__moonbitReactErrorBoundary ??= class
  #|     MoonBitReactErrorBoundary extends globalThis.React.Component {
  #|       constructor(props) {
  #|         super(props);
  #|         this.state = { error: null };
  #|       }
  #|       static getDerivedStateFromError(error) {
  #|         return { error };
  #|       }
  #|       componentDidCatch(error, info) {
  #|         this.props.onError?.(error, info);
  #|       }
  #|       render() {
  #|         return this.state.error == null
  #|           ? this.props.children
  #|           : this.props.fallback(this.state.error);
  #|       }
  #|     };
  #|   return globalThis.React.createElement(
  #|     Boundary,
  #|     {
  #|       key: resetKey ?? undefined,
  #|       fallback,
  #|       onError: onError ?? undefined,
  #|       resetKey: resetKey ?? undefined,
  #|     },
  #|     ...children,
  #|   );
  #| }

///|
/// Creates a local React Error Boundary around `children`.
///
/// Render failures and rejected resources produce `fallback(error)`. Changing
/// `reset_key` remounts the boundary and retries its children. `on_error`
/// receives React's component stack after the fallback commits. Event-handler
/// and arbitrary asynchronous errors outside render are not caught.
pub fn error_boundary(
  fallback : (ReactError) -> VirtualNode,
  children : Array[VirtualNode],
  reset_key? : String,
  on_error? : (ReactError, ReactErrorInfo) -> Unit,
) -> VirtualNode {
  let js_reset_key = match reset_key {
    Some(value) => @dom.JsObscure::from_string(value)
    None => @dom.JsObscure::null()
  }
  let js_on_error = match on_error {
    Some(callback) => @dom.v_to_js_obscure(callback)
    None => @dom.JsObscure::null()
  }
  JsNode(
    react_error_boundary(
      @dom.v_to_js_obscure(fn(error : ReactError) {
        fallback(error).to_js_obscure()
      }),
      js_on_error,
      js_reset_key,
      FixedArray::from_array(children.map(fn(child) { child.to_js_obscure() })),
    ),
  )
}
