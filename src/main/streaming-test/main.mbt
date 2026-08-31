///|
struct StreamContentProps {
  resource : @react.ReactResource[String]
}

///|
struct StreamTreeProps {
  resource : @react.ReactResource[String]
}

///|
struct StreamChunkProbe {
  first : String
  rest : String
  chunks : Int
}

///|
extern "js" fn stream_test_reset_pending() -> Unit =
  #| () => {
  #|   let resolve;
  #|   const promise = new Promise((resolvePromise) => {
  #|     resolve = resolvePromise;
  #|   });
  #|   globalThis.__moonbitStreamingTest = {
  #|     promise,
  #|     resolve,
  #|     errors: [],
  #|   };
  #| }

///|
extern "js" fn stream_test_pending_promise() -> @js_async.Promise[String] =
  #| () => globalThis.__moonbitStreamingTest.promise

///|
extern "js" fn stream_test_resolved_promise() -> @js_async.Promise[String] =
  #| () => Promise.resolve("static content")

///|
extern "js" fn stream_test_record_error(error : @react.ReactError) -> Unit =
  #| (error) => globalThis.__moonbitStreamingTest.errors.push(
  #|   error?.message ?? String(error),
  #| )

///|
extern "js" fn stream_test_error_count() -> Int =
  #| () => globalThis.__moonbitStreamingTest.errors.length

///|
extern "js" fn stream_test_first_error() -> String =
  #| () => globalThis.__moonbitStreamingTest.errors[0] ?? ""

///|
extern "js" fn stream_test_contains(text : String, value : String) -> Bool =
  #| (text, value) => text.includes(value)

///|
extern "js" fn stream_test_probe_progressive(
  stream : @js_async.JsReadableStream,
) -> @js_async.Promise[StreamChunkProbe] =
  #| async (stream) => {
  #|   const reader = stream.getReader();
  #|   const decoder = new TextDecoder();
  #|   const firstRead = await reader.read();
  #|   const first = firstRead.done ? "" : decoder.decode(firstRead.value, { stream: true });
  #|   let chunks = firstRead.done ? 0 : 1;
  #|   globalThis.__moonbitStreamingTest.resolve("streamed content");
  #|   let rest = "";
  #|   while (true) {
  #|     const next = await reader.read();
  #|     if (next.done) break;
  #|     chunks += 1;
  #|     rest += decoder.decode(next.value, { stream: true });
  #|   }
  #|   rest += decoder.decode();
  #|   return { first, rest, chunks };
  #| }

///|
fn comp_stream_content(props : StreamContentProps) -> @react.VirtualNode {
  let content = @react.use_resource(props.resource)
  @react.p(id="stream-content", [Text(content)])
}

///|
fn comp_stream_tree(props : StreamTreeProps) -> @react.VirtualNode {
  let generated_id = @react.use_id()
  @react.section(id="stream-shell", [
    @react.p(id="stream-generated-id", [Text(generated_id)]),
    @react.suspense(@react.p(id="stream-fallback", [Text("stream pending")]), [
      @react.component(
        comp_stream_content,
        StreamContentProps::{ resource: props.resource },
        [],
      ),
    ]),
  ])
}

///|
fn stream_tree(resource : @react.ReactResource[String]) -> @react.VirtualNode {
  @react.component(comp_stream_tree, StreamTreeProps::{ resource, }, [])
}

///|
extern "js" fn require(condition : Bool, message : String) -> Unit =
  #| (condition, message) => {
  #|   if (!condition) throw new Error(message);
  #| }

///|
async fn main {
  stream_test_reset_pending()
  let progressive = @react.render_to_readable_stream(
    stream_tree(@react.resource_from_promise(stream_test_pending_promise())),
    options=@react.StreamRenderOptions::new(
      identifier_prefix="node-stream-",
      bootstrap_scripts=["/hydrate.js"],
      nonce="stream-nonce",
      on_error=stream_test_record_error,
    ),
  )
  let probe = stream_test_probe_progressive(progressive.to_js_readable_stream()).wait()
  progressive.wait_all_ready()
  require(
    stream_test_contains(probe.first, "stream-shell"),
    "first chunk must contain the shell",
  )
  require(
    stream_test_contains(probe.first, "stream pending"),
    "first chunk must contain the Suspense fallback",
  )
  require(
    !stream_test_contains(probe.first, "streamed content"),
    "first chunk must precede resolved content",
  )
  require(
    stream_test_contains(probe.rest, "streamed content"),
    "later chunks must contain resolved content",
  )
  let progressive_html = probe.first + probe.rest
  require(
    stream_test_contains(progressive_html, "/hydrate.js"),
    "progressive HTML must include the configured bootstrap script",
  )
  require(
    stream_test_contains(progressive_html, "stream-nonce"),
    "progressive HTML must include the configured CSP nonce",
  )
  require(probe.chunks >= 2, "progressive rendering must emit multiple chunks")
  require(
    stream_test_error_count() == 0,
    "progressive rendering must be error-free",
  )

  stream_test_reset_pending()
  let static_stream = @react.render_to_readable_stream(
    stream_tree(@react.resource_from_promise(stream_test_resolved_promise())),
    options=@react.StreamRenderOptions::new(
      identifier_prefix="static-stream-",
      on_error=stream_test_record_error,
    ),
  )
  static_stream.wait_all_ready()
  let static_html = static_stream.read_text()
  require(
    stream_test_contains(static_html, "static content"),
    "allReady HTML must contain resolved content",
  )
  require(
    stream_test_contains(static_html, "static-stream-"),
    "allReady HTML must use the configured identifier prefix",
  )
  require(
    stream_test_error_count() == 0,
    "allReady rendering must be error-free",
  )

  stream_test_reset_pending()
  let aborted = @react.render_to_readable_stream(
    stream_tree(@react.resource_from_promise(stream_test_pending_promise())),
    options=@react.StreamRenderOptions::new(on_error=stream_test_record_error),
  )
  aborted.abort(reason="intentional stream abort")
  let aborted_html = aborted.read_text()
  require(
    stream_test_contains(aborted_html, "stream pending"),
    "aborted rendering must retain the Suspense fallback",
  )
  require(
    stream_test_error_count() == 1,
    "abort must report exactly one server error",
  )
  require(
    stream_test_contains(stream_test_first_error(), "intentional stream abort"),
    "abort error must preserve its reason",
  )

  println(
    "Streaming SSR passed: progressive chunks=\{probe.chunks}, allReady=1, abortErrors=\{stream_test_error_count()}",
  )
}
