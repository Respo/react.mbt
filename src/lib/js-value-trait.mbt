///|
pub(open) trait JsValueTrait {
  to_value(Self) -> JsValue
  from_value(JsValue) -> Self
}

///|
impl JsValueTrait for String with to_value(self) -> JsValue {
  JsValue::from_string(self)
}

///|
impl JsValueTrait for String with from_value(value : JsValue) -> String {
  value.to_string()
}

///|
impl JsValueTrait for Float with from_value(value : JsValue) -> Float {
  value.to_number()
}

///|
impl JsValueTrait for Float with to_value(self) -> JsValue {
  JsValue::from_number(self)
}

///|
impl JsValueTrait for Bool with to_value(self) -> JsValue {
  JsValue::from_bool(self)
}

///|
impl JsValueTrait for Bool with from_value(value : JsValue) -> Bool {
  value.to_bool()
}

///|
impl JsValueTrait for JsObject with to_value(self) -> JsValue {
  JsValue::from_object(self)
}

///|
impl JsValueTrait for JsObject with from_value(value : JsValue) -> JsObject {
  value.to_object()
}

///|
impl JsValueTrait for JsArray with to_value(self) -> JsValue {
  JsValue::from_array(self)
}

///|
impl JsValueTrait for JsArray with from_value(value : JsValue) -> JsArray {
  value.to_array()
}
