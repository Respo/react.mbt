///|
struct ConformanceProbeProps {
  version : Int
}

///|
struct ConformanceControllerProps {
  target : @dom.Element
}

///|
struct PortalOwnerProps {
  target : @dom.Element
}

///|
struct PortalControllerProps {
  owner : @dom.Element
}

///|
struct HydrationProbeProps {}

///|
struct RootErrorControllerProps {
  caught_target : @dom.Element
  uncaught_target : @dom.Element
  recoverable_target : @dom.Element
}

///|
struct ActivityProbeProps {}

///|
struct ActivityControllerProps {}

///|
extern "js" fn conformance_reset_observations() -> Unit =
  #| () => {
  #|   globalThis.__moonbitReactConformance = {
  #|     renders: 0,
  #|     setups: 0,
  #|     cleanups: 0,
  #|     ref: null,
  #|     nativeEvents: { pointer: null, wheel: null },
  #|   };
  #| }

///|
extern "js" fn conformance_record_render(js_ref : @dom.JsObscure) -> Unit =
  #| (jsRef) => {
  #|   const observations = globalThis.__moonbitReactConformance;
  #|   observations.renders += 1;
  #|   observations.ref = jsRef;
  #| }

///|
extern "js" fn conformance_record_setup() -> Unit =
  #| () => globalThis.__moonbitReactConformance.setups += 1

///|
extern "js" fn conformance_record_cleanup() -> Unit =
  #| () => globalThis.__moonbitReactConformance.cleanups += 1

///|
extern "js" fn conformance_record_native_pointer(
  pointer_id : Int,
  button : Int,
  buttons : Int,
  pressure : Float,
  client_x : Float,
  client_y : Float,
) -> Unit =
  #| (pointerId, button, buttons, pressure, clientX, clientY) => {
  #|   globalThis.__moonbitReactConformance.nativeEvents.pointer = {
  #|     pointerId, button, buttons, pressure, clientX, clientY,
  #|   };
  #| }

///|
extern "js" fn conformance_record_native_wheel(
  delta_x : Float,
  delta_y : Float,
  delta_mode : Int,
) -> Unit =
  #| (deltaX, deltaY, deltaMode) => {
  #|   globalThis.__moonbitReactConformance.nativeEvents.wheel = {
  #|     deltaX, deltaY, deltaMode,
  #|   };
  #| }

///|
extern "js" fn conformance_reset_activity_observations() -> Unit =
  #| () => {
  #|   globalThis.__moonbitReactActivity = {
  #|     renders: 0,
  #|     mounts: 0,
  #|     cleanups: 0,
  #|     increment: null,
  #|   };
  #| }

///|
extern "js" fn conformance_record_activity_render() -> Unit =
  #| () => globalThis.__moonbitReactActivity.renders += 1

///|
extern "js" fn conformance_record_activity_mount() -> Unit =
  #| () => globalThis.__moonbitReactActivity.mounts += 1

///|
extern "js" fn conformance_record_activity_cleanup() -> Unit =
  #| () => globalThis.__moonbitReactActivity.cleanups += 1

///|
extern "js" fn conformance_register_activity_increment(
  increment : @dom.JsObscure,
) -> Unit =
  #| (increment) => globalThis.__moonbitReactActivity.increment = increment

///|
extern "js" fn conformance_increment_hidden_activity() -> Unit =
  #| () => globalThis.__moonbitReactActivity.increment?.()

///|
extern "js" fn conformance_focus_ref(js_ref : @dom.JsObscure) -> Unit =
  #| (jsRef) => jsRef.current?.focus()

///|
extern "js" fn conformance_strict_mode(
  child : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (child) => globalThis.React.createElement(globalThis.React.StrictMode, null, child)

///|
extern "js" fn conformance_reset_root_integrations() -> Unit =
  #| () => {
  #|   globalThis.__moonbitReactRootIntegration = {
  #|     hydrationNode: null,
  #|     errors: {
  #|       hydration: [],
  #|       caught: [],
  #|       uncaught: [],
  #|       recoverable: [],
  #|     },
  #|   };
  #| }

///|
extern "js" fn conformance_prepare_hydration(
  target : @dom.Element,
  html : String,
) -> Unit =
  #| (target, html) => {
  #|   target.innerHTML = html;
  #|   globalThis.__moonbitReactRootIntegration.hydrationNode =
  #|     target.firstElementChild;
  #| }

///|
extern "js" fn conformance_prepare_recoverable_error(
  target : @dom.Element,
) -> Unit =
  #| (target) => {
  #|   target.innerHTML =
  #|     '<button id="recoverable-error-result">server value</button>';
  #| }

///|
extern "js" fn conformance_record_root_error(
  kind : String,
  message : String,
  component_stack : String,
) -> Unit =
  #| (kind, message, componentStack) => {
  #|   globalThis.__moonbitReactRootIntegration.errors[kind].push({
  #|     message,
  #|     componentStack,
  #|   });
  #| }

///|
extern "js" fn conformance_error_node(kind : String) -> @dom.JsObscure =
  #| (kind) => {
  #|   if (kind === "caught") {
  #|     function MoonBitCaughtThrower() {
  #|       throw new Error("caught root error");
  #|     }
  #|     class MoonBitConformanceBoundary extends globalThis.React.Component {
  #|       constructor(props) {
  #|         super(props);
  #|         this.state = { failed: false };
  #|       }
  #|       static getDerivedStateFromError() {
  #|         return { failed: true };
  #|       }
  #|       render() {
  #|         return this.state.failed
  #|           ? globalThis.React.createElement(
  #|               "p",
  #|               { id: "caught-error-result" },
  #|               "caught fallback",
  #|             )
  #|           : this.props.children;
  #|       }
  #|     }
  #|     return globalThis.React.createElement(
  #|       MoonBitConformanceBoundary,
  #|       null,
  #|       globalThis.React.createElement(MoonBitCaughtThrower),
  #|     );
  #|   }
  #|   function MoonBitUncaughtThrower() {
  #|     throw new Error("uncaught root error");
  #|   }
  #|   return globalThis.React.createElement(MoonBitUncaughtThrower);
  #| }

///|
extern "js" fn conformance_recoverable_node() -> @dom.JsObscure =
  #| () => globalThis.React.createElement(
  #|   "button",
  #|   { id: "recoverable-error-result" },
  #|   "client value",
  #| )

///|
fn strict_mode(child : VirtualNode) -> VirtualNode {
  JsNode(conformance_strict_mode(child.to_js_obscure()))
}

///|
fn comp_activity_probe(_props : ActivityProbeProps) -> VirtualNode {
  let (count, set_count) = @react.use_state_with_updater(0)
  let increment = fn() { set_count(@react.Update(fn(current) { current + 1 })) }
  conformance_record_activity_render()
  conformance_register_activity_increment(@react.obscure(increment))
  @react.use_effect_once_with_cleanup(fn() {
    conformance_record_activity_mount()
    fn() { conformance_record_activity_cleanup() }
  })
  @react.section(id="activity-probe", [
    @react.p(id="activity-state", [Text("Activity state: \{count}")]),
    @react.button(
      id="activity-visible-increment",
      on_click=fn(_) { increment() },
      [Text("Increment visible Activity")],
    ),
  ])
}

///|
fn comp_activity_controller(_props : ActivityControllerProps) -> VirtualNode {
  let (visible, set_visible) = @react.use_state(true)
  @react.div(id="activity-controller", [
    @react.button(
      id="activity-hide",
      disabled=!visible,
      on_click=fn(_) { set_visible(false) },
      [Text("Hide Activity")],
    ),
    @react.button(
      id="activity-hidden-increment",
      on_click=fn(_) { conformance_increment_hidden_activity() },
      [Text("Increment hidden Activity")],
    ),
    @react.button(
      id="activity-show",
      disabled=visible,
      on_click=fn(_) { set_visible(true) },
      [Text("Show Activity")],
    ),
    @react.activity(
      if visible {
        @react.ActivityMode::Visible
      } else {
        @react.ActivityMode::Hidden
      },
      [@react.component(comp_activity_probe, ActivityProbeProps::{  }, [])],
    ),
  ])
}

///|
fn run_activity_conformance() -> Unit {
  let doc = @dom.window().document()
  match doc.get_element_by_id("react-activity-root") {
    Some(target) => {
      conformance_reset_activity_observations()
      @react.render(
        @react.component(
          comp_activity_controller,
          ActivityControllerProps::{  },
          [],
        ),
        target,
      )
    }
    None => ()
  }
}

///|
fn record_root_error(
  kind : String,
  error : @react.ReactError,
  info : @react.ReactErrorInfo,
) -> Unit {
  conformance_record_root_error(kind, error.message(), info.component_stack())
}

///|
fn comp_portal_owner(props : PortalOwnerProps) -> VirtualNode {
  let (clicks, set_clicks) = @react.use_state_with_updater(0)
  @react.div(
    id="portal-react-owner",
    on_click=fn(_) { set_clicks(@react.Update(fn(current) { current + 1 })) },
    [
      @react.p(id="portal-event-count", [Text("Portal events: \{clicks}")]),
      @react.create_portal(
        @react.button(id="portal-event-button", [Text("Portal event")]),
        props.target,
        key="conformance-portal",
      ),
    ],
  )
}

///|
fn comp_portal_controller(props : PortalControllerProps) -> VirtualNode {
  @react.button(
    id="portal-unmount-owner",
    on_click=fn(_) { @react.unmount(props.owner) },
    [Text("Unmount portal owner")],
  )
}

///|
fn comp_hydration_probe(_props : HydrationProbeProps) -> VirtualNode {
  let (clicks, set_clicks) = @react.use_state_with_updater(0)
  let generated_id = @react.use_id()
  @react.section(id="hydration-probe", [
    @react.p(id="hydration-generated-id", [Text(generated_id)]),
    @react.button(
      id="hydration-event-button",
      on_click=fn(_) { set_clicks(@react.Update(fn(current) { current + 1 })) },
      [Text("Hydration events: \{clicks}")],
    ),
  ])
}

///|
fn hydration_probe() -> VirtualNode {
  @react.component(comp_hydration_probe, HydrationProbeProps::{  }, [])
}

///|
fn run_caught_error(target : @dom.Element) -> Unit {
  @react.render_with_options(
    JsNode(conformance_error_node("caught")),
    target,
    @react.RootOptions::new(on_caught_error=fn(error, info) {
      record_root_error("caught", error, info)
    }),
  )
}

///|
fn run_uncaught_error(target : @dom.Element) -> Unit {
  @react.render_with_options(
    JsNode(conformance_error_node("uncaught")),
    target,
    @react.RootOptions::new(on_uncaught_error=fn(error, info) {
      record_root_error("uncaught", error, info)
    }),
  )
}

///|
fn run_recoverable_error(target : @dom.Element) -> Unit {
  conformance_prepare_recoverable_error(target)
  @react.hydrate_root(
    JsNode(conformance_recoverable_node()),
    target,
    options=@react.RootOptions::new(on_recoverable_error=fn(error, info) {
      record_root_error("recoverable", error, info)
    }),
  )
}

///|
fn comp_root_error_controller(props : RootErrorControllerProps) -> VirtualNode {
  @react.div([
    @react.button(
      id="run-caught-root-error",
      on_click=fn(_) { run_caught_error(props.caught_target) },
      [Text("Run caught error")],
    ),
    @react.button(
      id="run-uncaught-root-error",
      on_click=fn(_) { run_uncaught_error(props.uncaught_target) },
      [Text("Run uncaught error")],
    ),
    @react.button(
      id="run-recoverable-root-error",
      on_click=fn(_) { run_recoverable_error(props.recoverable_target) },
      [Text("Run recoverable error")],
    ),
  ])
}

///|
fn run_portal_conformance() -> Unit {
  let doc = @dom.window().document()
  match
    (
      doc.get_element_by_id("react-portal-controller-root"),
      doc.get_element_by_id("react-portal-owner-root"),
      doc.get_element_by_id("react-portal-target"),
    ) {
    (Some(controller), Some(owner), Some(target)) => {
      @react.render(
        @react.component(comp_portal_controller, { owner, }, []),
        controller,
      )
      @react.render(@react.component(comp_portal_owner, { target, }, []), owner)
    }
    _ => ()
  }
}

///|
fn run_hydration_conformance() -> Unit {
  let doc = @dom.window().document()
  match doc.get_element_by_id("react-hydration-target") {
    Some(target) => {
      let prefix = "moonbit-hydration-"
      let html = @react.render_to_string(
        hydration_probe(),
        identifier_prefix=prefix,
      )
      conformance_prepare_hydration(target, html)
      @react.hydrate_root(
        hydration_probe(),
        target,
        options=@react.RootOptions::new(identifier_prefix=prefix, on_recoverable_error=fn(
          error,
          info,
        ) {
          record_root_error("hydration", error, info)
        }),
      )
    }
    None => ()
  }
}

///|
fn run_root_error_conformance() -> Unit {
  let doc = @dom.window().document()
  match
    (
      doc.get_element_by_id("react-root-errors-controller"),
      doc.get_element_by_id("react-caught-error-target"),
      doc.get_element_by_id("react-uncaught-error-target"),
      doc.get_element_by_id("react-recoverable-error-target"),
    ) {
    (Some(controller), Some(caught), Some(uncaught), Some(recoverable)) =>
      @react.render(
        @react.component(
          comp_root_error_controller,
          {
            caught_target: caught,
            uncaught_target: uncaught,
            recoverable_target: recoverable,
          },
          [],
        ),
        controller,
      )
    _ => ()
  }
}

///|
fn comp_conformance_probe(props : ConformanceProbeProps) -> VirtualNode {
  let (functional_count, set_functional_count) = @react.use_state_with_updater(
    0,
  )
  let (reducer_count, dispatch_reducer) = @react.use_reducer_with_initial(0, fn(
    current : Int,
    delta : Int,
  ) {
    current + delta
  })
  let input_ref = @react.use_ref(@dom.JsObscure::null())
  conformance_record_render(input_ref.to_js_obscure())
  @react.use_effect_once_with_cleanup(fn() {
    conformance_record_setup()
    fn() { conformance_record_cleanup() }
  })
  let input_attrs = @react.ElementAttrs::new()
  input_attrs.set_js_value("ref", input_ref.to_js_obscure())
  let pointer_events = @react.ElementEvents::new()
  pointer_events.set(@react.DOMEventType::PointerMove, fn(event) {
    match event.native_pointer_event() {
      Some(native) =>
        conformance_record_native_pointer(
          native.pointer_id(),
          native.button(),
          native.buttons(),
          native.pressure(),
          native.client_x(),
          native.client_y(),
        )
      None => ()
    }
  })
  let wheel_events = @react.ElementEvents::new()
  wheel_events.set(@react.DOMEventType::Wheel, fn(event) {
    match event.native_wheel_event() {
      Some(native) =>
        conformance_record_native_wheel(
          native.delta_x(),
          native.delta_y(),
          native.delta_mode(),
        )
      None => ()
    }
  })
  @react.section(
    id="react-conformance-probe",
    style=@css.respo_style(
      margin=10.0 |> @css.Px,
      padding=12.0 |> @css.Px,
      border=@css.CssBorder(1.0, @css.Solid, @css.Hsl(210, 20, 80)),
    ),
    [
      @react.h2([Text("React runtime conformance")]),
      @react.p(id="conformance-version", [
        Text("Render version: \{props.version}"),
      ]),
      @react.p(id="conformance-functional-count", [
        Text("Functional state: \{functional_count}"),
      ]),
      @react.p(id="conformance-reducer-count", [
        Text("Reducer state: \{reducer_count}"),
      ]),
      @react.input(
        id="conformance-ref-input",
        attrs=input_attrs,
        placeholder="DOM ref target",
      ),
      @react.button(
        id="conformance-functional-update",
        on_click=fn(_) {
          set_functional_count(@react.Update(fn(current) { current + 1 }))
          set_functional_count(@react.Update(fn(current) { current + 1 }))
        },
        [Text("Batch functional updates")],
      ),
      @react.button(
        id="conformance-reducer-dispatch",
        on_click=fn(_) {
          dispatch_reducer(1)
          dispatch_reducer(1)
        },
        [Text("Batch reducer dispatches")],
      ),
      @react.button(
        id="conformance-focus-ref",
        on_click=fn(_) { conformance_focus_ref(input_ref.to_js_obscure()) },
        [Text("Focus DOM ref")],
      ),
      @react.div(id="conformance-native-pointer", event=pointer_events, [
        Text("Native pointer payload probe"),
      ]),
      @react.div(id="conformance-native-wheel", event=wheel_events, [
        Text("Native wheel payload probe"),
      ]),
    ],
  )
}

///|
fn conformance_target(version : Int) -> VirtualNode {
  strict_mode(@react.component(comp_conformance_probe, { version, }, []))
}

///|
fn render_conformance_target(target : @dom.Element, version : Int) -> Unit {
  @react.render(conformance_target(version), target)
}

///|
fn comp_conformance_controller(
  props : ConformanceControllerProps,
) -> VirtualNode {
  let (version, set_version) = @react.use_state(0)
  let (mounted, set_mounted) = @react.use_state(true)
  @react.div(id="react-conformance-controller", [
    @react.button(
      id="conformance-rerender-root",
      disabled=!mounted,
      on_click=fn(_) {
        let next_version = version + 1
        render_conformance_target(props.target, next_version)
        set_version(next_version)
      },
      [Text("Render same root")],
    ),
    @react.button(
      id="conformance-toggle-root",
      on_click=fn(_) {
        if mounted {
          @react.unmount(props.target)
          set_mounted(false)
        } else {
          render_conformance_target(props.target, version)
          set_mounted(true)
        }
      },
      [Text(if mounted { "Unmount root" } else { "Mount root" })],
    ),
  ])
}

///|
fn run_conformance() -> Unit {
  let doc = @dom.window().document()
  match
    (
      doc.get_element_by_id("react-conformance-controller-root"),
      doc.get_element_by_id("react-conformance-target-root"),
    ) {
    (Some(controller), Some(target)) => {
      conformance_reset_observations()
      @react.render(
        @react.component(comp_conformance_controller, { target, }, []),
        controller,
      )
      render_conformance_target(target, 0)
    }
    _ => ()
  }
  conformance_reset_root_integrations()
  run_portal_conformance()
  run_hydration_conformance()
  run_root_error_conformance()
  run_activity_conformance()
}
