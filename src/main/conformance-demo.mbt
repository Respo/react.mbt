///|
struct ConformanceProbeProps {
  version : Int
}

///|
struct ConformanceControllerProps {
  target : @dom.Element
}

///|
extern "js" fn conformance_reset_observations() -> Unit =
  #| () => {
  #|   globalThis.__moonbitReactConformance = {
  #|     renders: 0,
  #|     setups: 0,
  #|     cleanups: 0,
  #|     ref: null,
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
extern "js" fn conformance_focus_ref(js_ref : @dom.JsObscure) -> Unit =
  #| (jsRef) => jsRef.current?.focus()

///|
extern "js" fn conformance_strict_mode(
  child : @dom.JsObscure,
) -> @dom.JsObscure =
  #| (child) => window.React.createElement(window.React.StrictMode, null, child)

///|
fn strict_mode(child : VirtualNode) -> VirtualNode {
  JsNode(conformance_strict_mode(child.to_js_obscure()))
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
}
