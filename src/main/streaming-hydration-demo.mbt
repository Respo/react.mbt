///|
struct StreamingHydrationProps {}

///|
extern "js" fn streaming_hydration_reset() -> Unit =
  #| () => {
  #|   globalThis.__moonbitStreamingHydration = {
  #|     serverNode: null,
  #|     htmlBytes: 0,
  #|     serverErrors: [],
  #|     recoverableErrors: [],
  #|   };
  #| }

///|
extern "js" fn streaming_hydration_prepare(
  target : @dom.Element,
  html : String,
) -> Unit =
  #| (target, html) => {
  #|   target.innerHTML = html;
  #|   const state = globalThis.__moonbitStreamingHydration;
  #|   state.serverNode = target.firstElementChild;
  #|   state.htmlBytes = new TextEncoder().encode(html).length;
  #| }

///|
extern "js" fn streaming_hydration_record_server_error(
  message : String,
) -> Unit =
  #| (message) => globalThis.__moonbitStreamingHydration.serverErrors.push(message)

///|
extern "js" fn streaming_hydration_record_recoverable_error(
  message : String,
) -> Unit =
  #| (message) => globalThis.__moonbitStreamingHydration.recoverableErrors.push(message)

///|
fn comp_streaming_hydration_probe(
  _props : StreamingHydrationProps,
) -> VirtualNode {
  let generated_id = @react.use_id()
  let (clicks, set_clicks) = @react.use_state_with_updater(0)
  @react.section(id="streaming-hydration-probe", [
    @react.p(id="streaming-hydration-id", [Text(generated_id)]),
    @react.button(
      id="streaming-hydration-button",
      on_click=fn(_) { set_clicks(@react.Update(fn(current) { current + 1 })) },
      [Text("Streaming hydration clicks: \{clicks}")],
    ),
  ])
}

///|
fn streaming_hydration_tree() -> VirtualNode {
  @react.component(
    comp_streaming_hydration_probe,
    StreamingHydrationProps::{  },
    [],
  )
}

///|
fn run_streaming_hydration_conformance() -> Unit {
  let doc = @dom.window().document()
  match doc.get_element_by_id("react-streaming-hydration-root") {
    Some(target) => {
      streaming_hydration_reset()
      let _task = @js_async.Promise::from_async(async fn() {
        let prefix = "moonbit-stream-"
        let stream = @react.render_to_readable_stream(
          streaming_hydration_tree(),
          options=@react.StreamRenderOptions::new(identifier_prefix=prefix, on_error=fn(
            error,
          ) {
            streaming_hydration_record_server_error(error.message())
          }),
        )
        stream.wait_all_ready()
        let html = stream.read_text()
        streaming_hydration_prepare(target, html)
        @react.hydrate_root(
          streaming_hydration_tree(),
          target,
          options=@react.RootOptions::new(identifier_prefix=prefix, on_recoverable_error=fn(
            error,
            _info,
          ) {
            streaming_hydration_record_recoverable_error(error.message())
          }),
        )
      })
    }
    None => ()
  }
}
