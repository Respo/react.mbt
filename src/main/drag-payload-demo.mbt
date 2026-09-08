///|
struct DragPayloadProps {}

///|
extern "js" fn record_drag_payload(
  event : @react.DOMEvent,
  transfer : @dom.JsObscure,
  text : String,
  names : Array[String],
) -> Unit =
  #| (event, transfer, text, names) => {
  #|   globalThis.__dragPayload.drops.push({text, names, present: transfer != null,
  #|     same: transfer === event.nativeEvent.dataTransfer,
  #|     prevented: event.isDefaultPrevented(), stopped: event.isPropagationStopped(),
  #|     trusted: event.nativeEvent.isTrusted});
  #| }

///|
extern "js" fn record_drag_start() -> Unit =
  #| () => { globalThis.__dragPayload.starts++; }

///|
extern "js" fn record_parent_drop() -> Unit =
  #| () => { globalThis.__dragPayload.parentDrops++; }

///|
fn comp_drag_payload(_props : DragPayloadProps) -> VirtualNode {
  let attrs = @react.ElementAttrs::new()
  attrs.set_bool("draggable", true)
  @react.div(
    event=@react.ElementEvents::new().add(@react.DOMEventType::Drop, fn(_) {
      record_parent_drop()
    }),
    [
      @react.div(
        id="payload-drag-source",
        attrs~,
        event=@react.ElementEvents::new().add(@react.DOMEventType::DragStart, fn(
          event,
        ) {
          match event.data_transfer() {
            Some(transfer) => {
              transfer.set_data("text/plain", "MoonBit drag")
              record_drag_start()
            }
            None => ()
          }
        }),
        [Text("Drag text from here")],
      ),
      @react.div(
        id="payload-drop-target",
        event=@react.ElementEvents::new()
          .add(@react.DOMEventType::DragOver, fn(event) {
            event.prevent_default()
          })
          .add(@react.DOMEventType::Drop, fn(event) {
            event.prevent_default()
            event.stop_propagation()
            match event.data_transfer() {
              Some(transfer) =>
                record_drag_payload(
                  event,
                  @dom.v_to_js_obscure(transfer),
                  transfer.get_data("text/plain"),
                  transfer.files().to_array().map(fn(file) { file.name() }),
                )
              None => record_drag_payload(event, @dom.JsObscure::null(), "", [])
            }
          }),
        [Text("Drop text or files here")],
      ),
    ],
  )
}

///|
extern "js" fn drag_payload_mount(
  probe : (@react.DOMEvent) -> Bool,
) -> @dom.JsObscure =
  #| (probe) => {
  #|   if (typeof document === "undefined" || !document.body) return null;
  #|   globalThis.__dragPayload = {starts: 0, parentDrops: 0, drops: [], present: probe};
  #|   const root = document.createElement("div");
  #|   document.body.appendChild(root);
  #|   return root;
  #| }

///|
fn run_drag_payload_conformance() -> Unit {
  let root = drag_payload_mount(fn(event) { event.data_transfer() is Some(_) })
  if root.is_nullish() {
    return
  }
  @react.render(
    @react.component(comp_drag_payload, DragPayloadProps::{  }, []),
    @dom.js_obscure_to_v(root),
  )
}
