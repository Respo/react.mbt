///|
type JsValue

///|
extern "js" fn JsValue::from_string(value : String) -> JsValue =
  #| (value) => value

///| unsafe
extern "js" fn JsValue::to_string(self : JsValue) -> String =
  #| (self) => self

///|
extern "js" fn JsValue::from_number(value : Float) -> JsValue =
  #| (value) => value

///| unsafe
extern "js" fn JsValue::to_number(self : JsValue) -> Float =
  #| (self) => self

///|
extern "js" fn JsValue::from_bool(value : Bool) -> JsValue =
  #| (value) => value

///| unsafe
extern "js" fn JsValue::to_bool(self : JsValue) -> Bool =
  #| (self) => self

///|
extern "js" fn JsValue::from_object(value : JsObject) -> JsValue =
  #| (value) => value

///| unsafe
extern "js" fn JsValue::to_object(self : JsValue) -> JsObject =
  #| (self) => self

///|
extern "js" fn JsValue::from_array(value : JsArray) -> JsValue =
  #| (value) => value

///| unsafe
extern "js" fn JsValue::to_array(self : JsValue) -> JsArray =
  #| (self) => self

///|
extern "js" fn JsValue::from_fn(value : () -> JsValue) -> JsValue =
  #| (value) => value

///| unsafe
extern "js" fn JsValue::to_fn(self : JsValue) -> () -> JsValue =
  #| (self) => self

///|
type JsObject

///|
extern "js" fn JsObject::new() -> JsObject =
  #| () => ({})

///|
extern "js" fn JsObject::set(
  self : JsObject,
  key : String,
  value : JsValue
) -> Unit =
  #| (self, key, value) => self[key] = value

///|
extern "js" fn JsObject::get(self : JsObject, key : String) -> JsValue =
  #| (self, key) => self[key]

///|
extern "js" fn JsObject::as_value(self : JsObject) -> JsValue =
  #| (self) => self

///|
type JsArray

///|
extern "js" fn JsArray::to_string(self : JsArray) -> String =
  #| (self) => `${self}`

///|
impl Show for JsArray with output(self, logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
extern "js" fn JsArray::new() -> JsArray =
  #| () => []

///|
extern "js" fn JsArray::op_get(self : JsArray, index : Int) -> JsValue =
  #| (self, index) => self[index]

///|
extern "js" fn JsArray::op_set(
  self : JsArray,
  index : Int,
  value : JsValue
) -> Unit =
  #| (self, index, value) => self[index] = value

///|
extern "js" fn JsArray::push(self : JsArray, value : JsValue) -> Unit =
  #| (self, value) => self.push(value)

///|
extern "js" fn JsArray::as_value(self : JsArray) -> JsValue =
  #| (self) => self
