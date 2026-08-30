export const commonProps = [
  { param: "role", react: "role", type: "String" },
  { param: "title", react: "title", type: "String" },
  { param: "tab_index", react: "tabIndex", type: "Int" },
  { param: "hidden", react: "hidden", type: "Bool" },
  { param: "aria_label", react: "aria-label", type: "String" },
  { param: "data_testid", react: "data-testid", type: "String" },
];

export const commonEvents = [
  { param: "on_click", variant: "Click" },
];

const string = (param, react = param) => ({ param, react, type: "String" });
const bool = (param, react = param) => ({ param, react, type: "Bool" });
const int = (param, react = param) => ({ param, react, type: "Int" });
const float = (param, react = param) => ({ param, react, type: "Float" });
const event = (param, variant) => ({ param, variant });

export const elements = [
  // Tables
  { name: "table", tag: "table", category: "table" },
  { name: "caption", tag: "caption", category: "table" },
  { name: "colgroup", tag: "colgroup", category: "table", props: [int("span")] },
  { name: "col", tag: "col", category: "table", void: true, props: [int("span")] },
  { name: "thead", tag: "thead", category: "table" },
  { name: "tbody", tag: "tbody", category: "table" },
  { name: "tfoot", tag: "tfoot", category: "table" },
  { name: "tr", tag: "tr", category: "table" },
  {
    name: "th",
    tag: "th",
    category: "table",
    props: [string("scope"), string("headers"), string("abbr"), int("col_span", "colSpan"), int("row_span", "rowSpan")],
  },
  {
    name: "td",
    tag: "td",
    category: "table",
    props: [string("headers"), int("col_span", "colSpan"), int("row_span", "rowSpan")],
  },

  // Form-related elements not covered by the specialized handwritten controls.
  { name: "fieldset", tag: "fieldset", category: "form", props: [string("name"), bool("disabled")] },
  { name: "legend", tag: "legend", category: "form" },
  { name: "datalist", tag: "datalist", category: "form" },
  { name: "optgroup", tag: "optgroup", category: "form", props: [string("label"), bool("disabled")] },
  { name: "output", tag: "output", category: "form", props: [string("name"), string("html_for", "htmlFor")] },
  { name: "progress", tag: "progress", category: "form", props: [float("value"), float("max")] },
  {
    name: "meter",
    tag: "meter",
    category: "form",
    props: [float("value"), float("min"), float("max"), float("low"), float("high"), float("optimum")],
  },

  // Interactive elements.
  {
    name: "dialog",
    tag: "dialog",
    category: "interactive",
    props: [bool("open")],
    events: [event("on_cancel", "Cancel"), event("on_close", "Close")],
  },
  { name: "details", tag: "details", category: "interactive", props: [bool("open")], events: [event("on_toggle", "Toggle")] },
  { name: "summary", tag: "summary", category: "interactive" },

  // React 19 resource and metadata elements.
  { name: "title", tag: "title", category: "metadata" },
  {
    name: "meta",
    tag: "meta",
    category: "metadata",
    void: true,
    props: [string("name"), string("content"), string("charset", "charSet"), string("http_equiv", "httpEquiv"), string("item_prop", "itemProp")],
  },
  {
    name: "link",
    tag: "link",
    category: "metadata",
    void: true,
    props: [string("rel"), string("href"), string("media"), string("precedence"), string("cross_origin", "crossOrigin")],
  },
  { name: "style_tag", tag: "style", category: "metadata", props: [string("precedence"), string("href")] },
  {
    name: "script_tag",
    tag: "script",
    category: "metadata",
    props: [string("src"), string("type_", "type"), string("cross_origin", "crossOrigin"), bool("async_", "async")],
  },

  // Additional common semantic HTML.
  { name: "main_", tag: "main", category: "semantic" },
  { name: "address", tag: "address", category: "semantic" },
  { name: "figure", tag: "figure", category: "semantic" },
  { name: "figcaption", tag: "figcaption", category: "semantic" },
  { name: "blockquote", tag: "blockquote", category: "semantic", props: [string("cite")] },
  { name: "pre", tag: "pre", category: "semantic" },
  { name: "code", tag: "code", category: "semantic" },
  { name: "strong", tag: "strong", category: "semantic" },
  { name: "em", tag: "em", category: "semantic" },
  { name: "time_", tag: "time", category: "semantic", props: [string("date_time", "dateTime")] },

  // Core SVG building blocks. String coordinates preserve numbers, units, and percentages.
  {
    name: "svg",
    tag: "svg",
    category: "svg",
    props: [string("view_box", "viewBox"), string("width"), string("height"), string("xmlns"), string("fill"), string("stroke")],
  },
  { name: "g", tag: "g", category: "svg", props: [string("transform"), string("fill"), string("stroke")] },
  { name: "defs", tag: "defs", category: "svg" },
  { name: "symbol", tag: "symbol", category: "svg", props: [string("view_box", "viewBox")] },
  { name: "path", tag: "path", category: "svg", props: [string("d"), string("fill"), string("stroke"), string("stroke_width", "strokeWidth"), string("path_length", "pathLength")] },
  { name: "circle", tag: "circle", category: "svg", props: [string("cx"), string("cy"), string("r"), string("fill"), string("stroke"), string("stroke_width", "strokeWidth")] },
  { name: "ellipse", tag: "ellipse", category: "svg", props: [string("cx"), string("cy"), string("rx"), string("ry"), string("fill"), string("stroke")] },
  { name: "rect", tag: "rect", category: "svg", props: [string("x"), string("y"), string("width"), string("height"), string("rx"), string("ry"), string("fill"), string("stroke")] },
  { name: "line", tag: "line", category: "svg", props: [string("x1"), string("y1"), string("x2"), string("y2"), string("stroke"), string("stroke_width", "strokeWidth")] },
  { name: "polyline", tag: "polyline", category: "svg", props: [string("points"), string("fill"), string("stroke")] },
  { name: "polygon", tag: "polygon", category: "svg", props: [string("points"), string("fill"), string("stroke")] },
  { name: "clip_path", tag: "clipPath", category: "svg" },
  { name: "mask", tag: "mask", category: "svg", props: [string("x"), string("y"), string("width"), string("height")] },
  { name: "linear_gradient", tag: "linearGradient", category: "svg", props: [string("x1"), string("y1"), string("x2"), string("y2")] },
  { name: "radial_gradient", tag: "radialGradient", category: "svg", props: [string("cx"), string("cy"), string("r"), string("fx"), string("fy")] },
  { name: "stop", tag: "stop", category: "svg", props: [string("offset"), string("stop_color", "stopColor"), string("stop_opacity", "stopOpacity")] },
  { name: "svg_text", tag: "text", category: "svg", props: [string("x"), string("y"), string("dx"), string("dy"), string("text_anchor", "textAnchor"), string("fill")] },
  { name: "tspan", tag: "tspan", category: "svg", props: [string("x"), string("y"), string("dx"), string("dy")] },
  { name: "use_", tag: "use", category: "svg", props: [string("href"), string("xlink_href", "xlinkHref"), string("x"), string("y"), string("width"), string("height")] },
];
