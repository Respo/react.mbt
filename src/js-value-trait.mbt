///|
pub(open) trait JsValueTrait {
  to_value(Self) -> JsValue
  from_value(JsValue) -> Self
}

///|
pub(open) trait CastJsValueTrait {
  to_js_value(Self) -> JsValue = _
}

///|
impl CastJsValueTrait with to_js_value(self) -> JsValue = "%identity"

///|
pub impl JsValueTrait for String with to_value(self) -> JsValue {
  JsValue::from_string(self)
}

///|
pub impl JsValueTrait for String with from_value(value : JsValue) -> String {
  value.to_string()
}

///|
pub impl JsValueTrait for Float with from_value(value : JsValue) -> Float {
  value.to_number()
}

///|
pub impl JsValueTrait for Float with to_value(self) -> JsValue {
  JsValue::from_number(self)
}

///|
pub impl JsValueTrait for Int with from_value(value : JsValue) -> Int {
  value.to_number().reinterpret_as_int()
}

///|
pub impl JsValueTrait for Int with to_value(self) -> JsValue {
  JsValue::from_number(self.reinterpret_as_float())
}

///|
pub impl JsValueTrait for Bool with to_value(self) -> JsValue {
  JsValue::from_bool(self)
}

///|
pub impl JsValueTrait for Bool with from_value(value : JsValue) -> Bool {
  value.to_bool()
}

///|
pub impl JsValueTrait for JsObject with to_value(self) -> JsValue {
  JsValue::from_object(self)
}

///|
pub impl JsValueTrait for JsObject with from_value(value : JsValue) -> JsObject {
  value.to_object()
}

///|
pub impl JsValueTrait for JsArray with to_value(self) -> JsValue {
  JsValue::from_array(self)
}

///|
pub impl JsValueTrait for JsArray with from_value(value : JsValue) -> JsArray {
  value.to_array()
}
