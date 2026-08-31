///|
struct DomOperationsProps {}

///|
extern "js" fn dom_operations_reset() -> Unit =
  #| () => {
  #|   globalThis.__moonbitDomOperations = {
  #|     flushBefore: "",
  #|     flushAfter: "",
  #|   };
  #| }

///|
extern "js" fn dom_operations_text(id : String) -> String =
  #| (id) => document.getElementById(id)?.textContent ?? ""

///|
extern "js" fn dom_operations_record_flush(
  before : String,
  after : String,
) -> Unit =
  #| (before, after) => {
  #|   globalThis.__moonbitDomOperations.flushBefore = before;
  #|   globalThis.__moonbitDomOperations.flushAfter = after;
  #| }

///|
fn comp_dom_operations(_props : DomOperationsProps) -> VirtualNode {
  let (count, set_count) = @react.use_state_with_updater(0)
  @react.section(id="dom-operations-probe", [
    @react.p(id="flush-sync-value", [Text("Flush value: \{count}")]),
    @react.button(
      id="flush-sync-button",
      on_click=fn(_) {
        let before = dom_operations_text("flush-sync-value")
        @react.flush_sync(fn() {
          set_count(@react.Update(fn(current) { current + 1 }))
        })
        let after = dom_operations_text("flush-sync-value")
        dom_operations_record_flush(before, after)
      },
      [Text("Flush synchronously")],
    ),
  ])
}

///|
fn emit_resource_hints() -> Unit {
  @react.prefetch_dns("https://resource-hints.invalid")
  @react.preconnect(
    "https://resource-hints.invalid",
    cross_origin=@react.ResourceCrossOrigin::Anonymous,
  )
  @react.preload(
    "data:text/css,%2Emoonbit-preload%7B%7D",
    @react.PreloadOptions::new(
      @react.PreloadDestination::Style,
      mime_type="text/css",
      fetch_priority=@react.ResourceFetchPriority::High,
    ),
  )
  @react.preload_module(
    "data:text/javascript,export%20default%201",
    options=@react.ModuleHintOptions::new(
      cross_origin=@react.ResourceCrossOrigin::Anonymous,
    ),
  )
  @react.preinit(
    "data:text/css,%2Emoonbit-preinit%7B%7D",
    @react.PreinitOptions::style(@react.ResourceStylePrecedence::Low),
  )
  @react.preinit_module("data:text/javascript,")
}

///|
fn run_dom_operations_conformance() -> Unit {
  dom_operations_reset()
  emit_resource_hints()
  // React promises that equivalent resource hints have the effect of one call.
  emit_resource_hints()
  let doc = @dom.window().document()
  match doc.get_element_by_id("react-dom-operations-root") {
    Some(target) =>
      @react.render(
        @react.component(comp_dom_operations, DomOperationsProps::{  }, []),
        target,
      )
    None => ()
  }
}
