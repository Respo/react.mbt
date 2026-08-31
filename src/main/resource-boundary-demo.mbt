///|
struct ResourceReaderProps {
  resource : @react.ReactResource[String]
  id : String
  prefix : String
}

///|
struct ResourceControllerProps {
  success : @react.ReactResource[String]
  failure : @react.ReactResource[String]
  retry : @react.ReactResource[String]
}

///|
extern "js" fn resource_conformance_reset() -> Unit =
  #| () => {
  #|   const deferred = () => {
  #|     let resolve;
  #|     let reject;
  #|     const promise = new Promise((resolvePromise, rejectPromise) => {
  #|       resolve = resolvePromise;
  #|       reject = rejectPromise;
  #|     });
  #|     return { promise, resolve, reject };
  #|   };
  #|   globalThis.__moonbitReactResources = {
  #|     success: deferred(),
  #|     failure: deferred(),
  #|     retryPromise: Promise.resolve("recovered value"),
  #|     metrics: {
  #|       resolves: 0,
  #|       rejects: 0,
  #|       localErrors: 0,
  #|       rootCaughtErrors: 0,
  #|       fallbackRenders: 0,
  #|       retries: 0,
  #|     },
  #|   };
  #| }

///|
extern "js" fn resource_success_promise() -> @js_async.Promise[String] =
  #| () => globalThis.__moonbitReactResources.success.promise

///|
extern "js" fn resource_failure_promise() -> @js_async.Promise[String] =
  #| () => globalThis.__moonbitReactResources.failure.promise

///|
extern "js" fn resource_retry_promise() -> @js_async.Promise[String] =
  #| () => globalThis.__moonbitReactResources.retryPromise

///|
extern "js" fn resource_resolve_success() -> Unit =
  #| () => {
  #|   const state = globalThis.__moonbitReactResources;
  #|   state.metrics.resolves += 1;
  #|   state.success.resolve("resolved value");
  #| }

///|
extern "js" fn resource_reject_failure() -> Unit =
  #| () => {
  #|   const state = globalThis.__moonbitReactResources;
  #|   state.metrics.rejects += 1;
  #|   state.failure.reject(new Error("resource rejected"));
  #| }

///|
extern "js" fn resource_record_local_error() -> Unit =
  #| () => globalThis.__moonbitReactResources.metrics.localErrors += 1

///|
extern "js" fn resource_record_root_caught_error() -> Unit =
  #| () => globalThis.__moonbitReactResources.metrics.rootCaughtErrors += 1

///|
extern "js" fn resource_record_fallback_render() -> Unit =
  #| () => globalThis.__moonbitReactResources.metrics.fallbackRenders += 1

///|
extern "js" fn resource_record_retry() -> Unit =
  #| () => globalThis.__moonbitReactResources.metrics.retries += 1

///|
fn comp_resource_reader(props : ResourceReaderProps) -> VirtualNode {
  let value = @react.use_resource(props.resource)
  @react.p(id=props.id, [Text("\{props.prefix}: \{value}")])
}

///|
fn comp_resource_controller(props : ResourceControllerProps) -> VirtualNode {
  let (retry_version, set_retry_version) = @react.use_state(0)
  let failure_resource = if retry_version == 0 {
    props.failure
  } else {
    props.retry
  }
  @react.section(id="resource-controller", [
    @react.button(
      id="resource-resolve-success",
      on_click=fn(_) { resource_resolve_success() },
      [Text("Resolve resource")],
    ),
    @react.suspense(
      @react.p(id="resource-success-pending", [Text("Success pending")]),
      [
        @react.component(
          comp_resource_reader,
          {
            resource: props.success,
            id: "resource-success-value",
            prefix: "Success",
          },
          [],
        ),
      ],
    ),
    @react.button(
      id="resource-reject-failure",
      on_click=fn(_) { resource_reject_failure() },
      [Text("Reject resource")],
    ),
    @react.button(
      id="resource-retry",
      on_click=fn(_) {
        resource_record_retry()
        set_retry_version(retry_version + 1)
      },
      [Text("Retry resource")],
    ),
    @react.error_boundary(
      fn(error) {
        resource_record_fallback_render()
        @react.p(id="resource-error-fallback", [
          Text("Resource error: \{error.message()}"),
        ])
      },
      [
        @react.suspense(
          @react.p(id="resource-failure-pending", [Text("Failure pending")]),
          [
            @react.component(
              comp_resource_reader,
              {
                resource: failure_resource,
                id: "resource-retry-value",
                prefix: "Retry",
              },
              [],
            ),
          ],
        ),
      ],
      reset_key="resource-retry-\{retry_version}",
      on_error=fn(_error, _info) { resource_record_local_error() },
    ),
  ])
}

///|
fn run_resource_boundary_conformance() -> Unit {
  let doc = @dom.window().document()
  match doc.get_element_by_id("react-resource-root") {
    Some(target) => {
      resource_conformance_reset()
      let props = ResourceControllerProps::{
        success: @react.resource_from_promise(resource_success_promise()),
        failure: @react.resource_from_promise(resource_failure_promise()),
        retry: @react.resource_from_promise(resource_retry_promise()),
      }
      @react.render_with_options(
        @react.component(comp_resource_controller, props, []),
        target,
        @react.RootOptions::new(on_caught_error=fn(_error, _info) {
          resource_record_root_caught_error()
        }),
      )
    }
    None => ()
  }
}
