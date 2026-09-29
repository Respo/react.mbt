///|
struct FormPayloadProps {}

///|
extern "js" fn form_payload_record_files_ffi(
  files : @dom.JsObscure,
  names : FixedArray[String],
) -> Unit =
  #| (files, names) => {
  #|   globalThis.__formPayload.files.push({
  #|     names, present: files != null,
  #|     same: files === document.getElementById("payload-files").files,
  #|   });
  #| }

fn form_payload_record_files(
  files : @dom.JsObscure,
  names : Array[String],
) -> Unit {
  form_payload_record_files_ffi(files, FixedArray::from_array(names))
}

///|
extern "js" fn form_payload_record_submit(
  element : @dom.JsObscure,
  event : @dom.JsObscure,
) -> Unit =
  #| (element, event) => {
  #|   globalThis.__formPayload.submits.push({
  #|     id: element?.id ?? null,
  #|     same: element === (event.nativeEvent.submitter ?? null),
  #|     prevented: event.isDefaultPrevented(),
  #|     stopped: event.isPropagationStopped(),
  #|   });
  #| }

///|
fn comp_form_payload(_props : FormPayloadProps) -> VirtualNode {
  let attrs = @react.ElementAttrs::new()
  attrs.set_bool("multiple", true)
  @react.form(
    id="payload-form",
    on_submit=fn(event) {
      event.prevent_default()
      event.stop_propagation()
      let element = match event.submitter() {
        Some(element) => @dom.v_to_js_obscure(element)
        None => @dom.JsObscure::null()
      }
      form_payload_record_submit(element, event.to_js_obscure())
    },
    [
      @react.input(id="payload-files", type_=@react.InputType::File, attrs~, on_change=fn(
        event,
      ) {
        match event.target_files() {
          Some(files) =>
            form_payload_record_files(
              @dom.v_to_js_obscure(files),
              files.to_array().map(fn(file) { file.name() }),
            )
          None => form_payload_record_files(@dom.JsObscure::null(), [])
        }
      }),
      @react.button(id="payload-save", [Text("Save payload")]),
      @react.button(id="payload-preview", [Text("Preview payload")]),
    ],
  )
}

///|
extern "js" fn form_payload_mount() -> @dom.JsObscure =
  #| () => {
  #|   if (typeof document === "undefined" || !document.body) return null;
  #|   globalThis.__formPayload = {files: [], submits: []};
  #|   const root = document.createElement("div");
  #|   document.body.appendChild(root);
  #|   return root;
  #| }

///|
extern "js" fn expose_form_payload_probes(
  files : (@react.DOMEvent) -> Bool,
  submitter : (@react.DOMEvent) -> Bool,
) -> Unit =
  #| (files, submitter) => {
  #|   globalThis.__formPayload.filesPresent = files;
  #|   globalThis.__formPayload.submitterPresent = submitter;
  #| }

///|
fn run_form_payload_conformance() -> Unit {
  let root = form_payload_mount()
  if root.is_nullish() {
    return
  }
  expose_form_payload_probes(fn(event) { event.target_files() is Some(_) }, fn(
    event,
  ) {
    event.submitter() is Some(_)
  })
  @react.render(
    @react.component(comp_form_payload, FormPayloadProps::{  }, []),
    @dom.js_obscure_to_v(root),
  )
}
