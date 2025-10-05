///|
pub(open) trait JsValueTrait {
  to_value(Self) -> @dom.JsObscure
  from_value(@dom.JsObscure) -> Self
}

///|
pub(open) trait CastJsValueTrait {
  to_js_value(Self) -> JsValue = _
}

///|
impl CastJsValueTrait with to_js_value(self) -> JsValue = "%identity"
