///|
struct GeneratedDomConformanceProps {}

///|
extern "js" fn reset_generated_dom_observations() -> Unit =
  #| () => {
  #|   globalThis.__moonbitGeneratedDomConformance = {
  #|     renders: 0,
  #|     cancels: 0,
  #|     closes: 0,
  #|     frameLoads: 0,
  #|   };
  #| }

///|
extern "js" fn record_generated_dom_observation(kind : String) -> Unit =
  #| (kind) => {
  #|   globalThis.__moonbitGeneratedDomConformance[kind] += 1;
  #| }

///|
fn comp_generated_dom_conformance(
  _props : GeneratedDomConformanceProps,
) -> VirtualNode {
  record_generated_dom_observation("renders")
  let custom_attrs = @react.ElementAttrs::new()
  custom_attrs.set("aria-live", "polite")
  custom_attrs.set("data-state", "ready")
  custom_attrs.set("customvalue", "opaque")
  @react.div([
    @react.iframe(
      id="generated-frame",
      title="Embedded fixture",
      src="about:blank",
      src_doc="<!doctype html><p id='frame-message'>Embedded ready</p>",
      name="generated-frame",
      sandbox="allow-same-origin",
      allow="fullscreen",
      allow_full_screen=false,
      loading="eager",
      referrer_policy="no-referrer",
      width=240,
      height=80,
      on_load=fn(_) { record_generated_dom_observation("frameLoads") },
      [],
    ),
    @react.canvas(id="generated-canvas", width=120, height=60, [
      Text("Canvas fallback"),
    ]),
    @react.picture(id="generated-picture", [
      @react.source(
        id="generated-source",
        src_set="data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='2'%20height='1'%3E%3C/svg%3E 1x",
        sizes="2px",
        type_="image/svg+xml",
        media="(min-width: 1px)",
        width=2,
        height=1,
      ),
      @react.img(
        id="generated-picture-img",
        src="data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='1'%20height='1'%3E%3C/svg%3E",
        alt="Responsive fixture",
      ),
    ]),
    @react.dl(id="generated-description", [
      @react.dt([Text("Language")]),
      @react.dd([Text("MoonBit")]),
    ]),
    @react.meta(name="react-mbt-generated-helper", content="metadata-ready"),
    @react.table(
      id="generated-table",
      aria_label="Generated scores",
      data_testid="generated-table",
      [
        @react.caption([Text("Generated scores")]),
        @react.thead([
          @react.tr([@react.th(scope="col", col_span=2, [Text("Team")])]),
        ]),
        @react.tbody([
          @react.tr([
            @react.td(headers="team", [Text("MoonBit")]),
            @react.td([Text("19")]),
          ]),
        ]),
      ],
    ),
    @react.fieldset(id="generated-fieldset", disabled=false, [
      @react.legend([Text("Generated form")]),
      @react.output(html_for="generated-progress", [Text("3.5/5")]),
      @react.progress(id="generated-progress", value=3.5, max=5.0, []),
    ]),
    @react.dialog(
      id="generated-dialog",
      open=false,
      on_cancel=fn(_) { record_generated_dom_observation("cancels") },
      on_close=fn(_) { record_generated_dom_observation("closes") },
      [Text("Generated dialog")],
    ),
    @react.svg(
      id="generated-svg",
      view_box="0 0 24 24",
      width="24",
      height="24",
      role="img",
      aria_label="Generated status icon",
      [
        @react.defs([
          @react.linear_gradient(id="generated-gradient", x1="0%", x2="100%", [
            @react.stop(offset="0%", stop_color="#ffffff", []),
          ]),
        ]),
        @react.path(
          id="generated-path",
          d="M2 12h20",
          stroke="currentColor",
          stroke_width="2",
          path_length="20",
          [],
        ),
        @react.use_(
          id="generated-use",
          href="#generated-path",
          xlink_href="#generated-path",
          [],
        ),
      ],
    ),
    @react.create_element(
      "moonbit-widget",
      custom_attrs,
      @react.ElementEvents::new(),
      style=@css.respo_style(),
      [Text("Custom escape hatch")],
    ).to_node(),
  ])
}

///|
fn run_generated_dom_conformance() -> Unit {
  reset_generated_dom_observations()
  match @dom.window().document().get_element_by_id("generated-dom-root") {
    Some(root) =>
      @react.render(
        @react.component(
          comp_generated_dom_conformance,
          GeneratedDomConformanceProps::{  },
          [],
        ),
        root,
      )
    None => ()
  }
}
