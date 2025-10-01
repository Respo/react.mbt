///|
type JsValue

///|
extern "js" fn JsValue::from_string(value : String) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_string(self : JsValue) -> String =
  #| (self) => self

///|
extern "js" fn JsValue::from_number(value : Float) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_number(self : JsValue) -> Float =
  #| (self) => self

///|
extern "js" fn JsValue::from_bool(value : Bool) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_bool(self : JsValue) -> Bool =
  #| (self) => self

///|
pub extern "js" fn JsValue::from_object(value : JsObject) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_object(self : JsValue) -> JsObject =
  #| (self) => self

///|
extern "js" fn JsValue::from_array(value : JsArray) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_array(self : JsValue) -> JsArray =
  #| (self) => self

///|
extern "js" fn JsValue::from_fn(value : () -> JsValue) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_fn(self : JsValue) -> () -> JsValue =
  #| (self) => self

///|
type JsObject

///|
pub extern "js" fn JsObject::new() -> JsObject =
  #| () => ({})

///|
extern "js" fn JsObject::set(
  self : JsObject,
  key : String,
  value : JsValue,
) -> Unit =
  #| (self, key, value) => self[key] = value

///|
pub extern "js" fn JsObject::get(self : JsObject, key : String) -> JsValue =
  #| (self, key) => self[key]

///|
/// Converts a JavaScript object to a JavaScript value.
///
/// Parameters:
///
/// * `self` : The JavaScript object to convert.
///
/// Returns a `JsValue` representing the same object.
///
/// Example:
///
/// ```moonbit
/// let obj = @tiye/react.JsObject::new()
/// let _value = obj.as_value()
/// ```
///
pub extern "js" fn JsObject::as_value(self : JsObject) -> JsValue =
  #| (self) => self

///|
pub type JsArray

///|
pub extern "js" fn JsArray::to_string(self : JsArray) -> String =
  #| (self) => `${self}`

///|
pub extern "js" fn JsArray::new() -> JsArray =
  #| () => []

///|
pub extern "js" fn JsArray::op_get(self : JsArray, index : Int) -> JsValue =
  #| (self, index) => self[index]

///|
pub extern "js" fn JsArray::op_set(
  self : JsArray,
  index : Int,
  value : JsValue,
) -> Unit =
  #| (self, index, value) => self[index] = value

///|
extern "js" fn JsArray::push(self : JsArray, value : JsValue) -> Unit =
  #| (self, value) => self.push(value)

///|
pub extern "js" fn JsArray::as_value(self : JsArray) -> JsValue =
  #| (self) => self
