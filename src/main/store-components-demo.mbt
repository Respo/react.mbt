///|
struct ExternalStoreProbeProps {}

///|
struct ExternalStoreControllerProps {
  consumer : @dom.Element
}

///|
struct IntegratedComponentProps {
  label : String
  marker : @dom.JsObscure
}

///|
struct ImperativeProbeProps {
  handle_ref : @react.ImperativeRef[String]
}

///|
struct ComponentIntegrationProps {}

///|
extern "js" fn reset_store_component_observations() -> Unit =
  #| () => {
  #|   let resolveLazy;
  #|   const lazyPromise = new Promise((resolve) => { resolveLazy = resolve; });
  #|   globalThis.__moonbitStoreComponentConformance = {
  #|     value: 0,
  #|     listeners: new Set(),
  #|     marker: {},
  #|     store: {
  #|       publications: 0,
  #|       deliveries: 0,
  #|       subscribes: 0,
  #|       unsubscribes: 0,
  #|       renders: 0,
  #|       committedSnapshots: [],
  #|     },
  #|     components: {
  #|       memoRenders: 0,
  #|       lazyLoads: 0,
  #|       lazyRenders: 0,
  #|       jsRenders: 0,
  #|       markerMatches: [],
  #|     },
  #|     lazyPromise,
  #|     resolveLazy,
  #|   };
  #| }

///|
extern "js" fn external_store_subscribe(notify : () -> Unit) -> () -> Unit =
  #| (notify) => {
  #|   const state = globalThis.__moonbitStoreComponentConformance;
  #|   let active = true;
  #|   state.store.subscribes += 1;
  #|   state.listeners.add(notify);
  #|   return () => {
  #|     if (active) {
  #|       active = false;
  #|       state.store.unsubscribes += 1;
  #|       state.listeners.delete(notify);
  #|     }
  #|   };
  #| }

///|
extern "js" fn external_store_snapshot() -> Int =
  #| () => globalThis.__moonbitStoreComponentConformance.value

///|
extern "js" fn external_store_publish(value : Int) -> Unit =
  #| (value) => {
  #|   const state = globalThis.__moonbitStoreComponentConformance;
  #|   state.value = value;
  #|   state.store.publications += 1;
  #|   for (const notify of [...state.listeners]) {
  #|     state.store.deliveries += 1;
  #|     notify();
  #|   }
  #| }

///|
extern "js" fn external_store_record_render(snapshot : Int) -> Unit =
  #| (snapshot) => {
  #|   const store = globalThis.__moonbitStoreComponentConformance.store;
  #|   store.renders += 1;
  #|   store.committedSnapshots.push(snapshot);
  #| }

///|
extern "js" fn component_integration_marker() -> @dom.JsObscure =
  #| () => globalThis.__moonbitStoreComponentConformance.marker

///|
extern "js" fn component_markers_equal(
  first : @dom.JsObscure,
  second : @dom.JsObscure,
) -> Bool =
  #| (first, second) => first === second

///|
extern "js" fn component_record_render(
  kind : String,
  marker : @dom.JsObscure,
) -> Unit =
  #| (kind, marker) => {
  #|   const state = globalThis.__moonbitStoreComponentConformance;
  #|   state.components[`${kind}Renders`] += 1;
  #|   state.components.markerMatches.push(marker === state.marker);
  #| }

///|
extern "js" fn component_lazy_wait() -> @js_async.Promise[Unit] =
  #| () => {
  #|   const state = globalThis.__moonbitStoreComponentConformance;
  #|   state.components.lazyLoads += 1;
  #|   return state.lazyPromise;
  #| }

///|
extern "js" fn component_resolve_lazy() -> Unit =
  #| () => globalThis.__moonbitStoreComponentConformance.resolveLazy()

///|
extern "js" fn component_js_type() -> @dom.JsObscure =
  #| () => function MoonBitJsInterop(props) {
  #|   const state = globalThis.__moonbitStoreComponentConformance;
  #|   const typed = props.moonbitProps;
  #|   state.components.jsRenders += 1;
  #|   state.components.markerMatches.push(typed.marker === state.marker);
  #|   return globalThis.React.createElement(
  #|     "p",
  #|     { id: "js-component-value" },
  #|     `JS component: ${typed.label}`,
  #|   );
  #| }

///|
fn comp_external_store_probe(_props : ExternalStoreProbeProps) -> VirtualNode {
  let snapshot = @react.use_sync_external_store(
    external_store_subscribe,
    external_store_snapshot,
    get_server_snapshot=external_store_snapshot,
  )
  external_store_record_render(snapshot)
  @react.p(id="external-store-snapshot", [Text("Store snapshot: \{snapshot}")])
}

///|
fn comp_external_store_controller(
  props : ExternalStoreControllerProps,
) -> VirtualNode {
  @react.div([
    @react.button(
      id="external-store-publish-one",
      on_click=fn(_) { external_store_publish(1) },
      [Text("Publish 1")],
    ),
    @react.button(
      id="external-store-publish-same",
      on_click=fn(_) { external_store_publish(1) },
      [Text("Publish same")],
    ),
    @react.button(
      id="external-store-publish-two",
      on_click=fn(_) { external_store_publish(2) },
      [Text("Publish 2")],
    ),
    @react.button(
      id="external-store-unmount",
      on_click=fn(_) { @react.unmount(props.consumer) },
      [Text("Unmount store")],
    ),
    @react.button(
      id="external-store-publish-after-unmount",
      on_click=fn(_) { external_store_publish(3) },
      [Text("Publish after unmount")],
    ),
  ])
}

///|
fn comp_memo_probe(props : IntegratedComponentProps) -> VirtualNode {
  component_record_render("memo", props.marker)
  @react.p(id="memo-component-value", [Text("Memo component: \{props.label}")])
}

///|
fn comp_lazy_probe(props : IntegratedComponentProps) -> VirtualNode {
  component_record_render("lazy", props.marker)
  @react.p(id="lazy-component-value", [Text("Lazy component: \{props.label}")])
}

///|
fn comp_imperative_probe(props : ImperativeProbeProps) -> VirtualNode {
  @react.use_imperative_handle_deps(props.handle_ref, fn() { "ready handle" }, [])
  @react.p(id="imperative-component-value", [Text("Imperative child mounted")])
}

///|
let memo_integration_component : @react.ReactComponent[IntegratedComponentProps] = @react.define_component(
  comp_memo_probe,
).memo(are_props_equal=fn(previous, next) {
  previous.label == next.label &&
  component_markers_equal(previous.marker, next.marker)
})

///|
let lazy_integration_component : @react.ReactComponent[IntegratedComponentProps] = @react.lazy_component(async fn() {
    component_lazy_wait().wait()
    @react.define_component(comp_lazy_probe)
  },
)

///|
let js_integration_component : @react.ReactComponent[IntegratedComponentProps] = @react.component_from_js(
  component_js_type(),
)

///|
fn comp_component_integration(
  _props : ComponentIntegrationProps,
) -> VirtualNode {
  let (label, set_label) = @react.use_state("stable")
  let (unrelated, set_unrelated) = @react.use_state_with_updater(0)
  let (show_lazy, set_show_lazy) = @react.use_state(true)
  let (show_imperative, set_show_imperative) = @react.use_state(true)
  let (handle_status, set_handle_status) = @react.use_state("unread")
  let handle_ref : @react.ImperativeRef[String] = @react.use_imperative_ref()
  let typed_props = IntegratedComponentProps::{
    label,
    marker: component_integration_marker(),
  }
  @react.div([
    @react.p(id="component-unrelated-value", [Text("Unrelated: \{unrelated}")]),
    memo_integration_component.render(typed_props),
    js_integration_component.render(typed_props),
    if show_lazy {
      @react.suspense(
        @react.p(id="lazy-component-fallback", [Text("Lazy loading")]),
        [lazy_integration_component.render(typed_props)],
      )
    } else {
      @react.p(id="lazy-component-hidden", [Text("Lazy hidden")])
    },
    if show_imperative {
      @react.component(
        comp_imperative_probe,
        ImperativeProbeProps::{ handle_ref, },
        [],
      )
    } else {
      @react.p(id="imperative-component-hidden", [Text("Imperative hidden")])
    },
    @react.p(id="imperative-handle-status", [Text("Handle: \{handle_status}")]),
    @react.button(
      id="component-unrelated-update",
      on_click=fn(_) {
        set_unrelated(@react.Update(fn(current) { current + 1 }))
      },
      [Text("Update unrelated")],
    ),
    @react.button(
      id="component-change-label",
      on_click=fn(_) { set_label("changed") },
      [Text("Change label")],
    ),
    @react.button(
      id="component-resolve-lazy",
      on_click=fn(_) { component_resolve_lazy() },
      [Text("Resolve lazy")],
    ),
    @react.button(
      id="component-toggle-lazy",
      on_click=fn(_) { set_show_lazy(!show_lazy) },
      [Text("Toggle lazy")],
    ),
    @react.button(
      id="component-read-handle",
      on_click=fn(_) {
        set_handle_status(handle_ref.current().unwrap_or("none"))
      },
      [Text("Read handle")],
    ),
    @react.button(
      id="component-toggle-imperative",
      on_click=fn(_) { set_show_imperative(!show_imperative) },
      [Text("Toggle imperative")],
    ),
  ])
}

///|
fn run_store_component_conformance() -> Unit {
  reset_store_component_observations()
  let doc = @dom.window().document()
  match
    (
      doc.get_element_by_id("external-store-controller-root"),
      doc.get_element_by_id("external-store-consumer-root"),
    ) {
    (Some(controller), Some(consumer)) => {
      @react.render(
        @react.component(
          comp_external_store_controller,
          ExternalStoreControllerProps::{ consumer, },
          [],
        ),
        controller,
      )
      @react.render(
        @react.component(
          comp_external_store_probe,
          ExternalStoreProbeProps::{  },
          [],
        ),
        consumer,
      )
    }
    _ => ()
  }
  match doc.get_element_by_id("component-integration-root") {
    Some(root) =>
      @react.render(
        @react.component(
          comp_component_integration,
          ComponentIntegrationProps::{  },
          [],
        ),
        root,
      )
    None => ()
  }
}
