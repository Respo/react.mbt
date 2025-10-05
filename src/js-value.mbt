///|
type JsValue

///|
extern "js" fn JsValue::from_object(value : JsObject) -> JsValue =
  #| (value) => value

///|
/// unsafe
extern "js" fn JsValue::to_array(self : JsValue) -> JsArray =
  #| (self) => self

///|
priv type JsObject

///|
extern "js" fn JsObject::new() -> JsObject =
  #| () => ({})

///|
extern "js" fn JsObject::set(
  self : JsObject,
  key : String,
  value : JsValue,
) -> Unit =
  #| (self, key, value) => self[key] = value

///|
pub type JsArray

///|
extern "js" fn JsArray::op_get(self : JsArray, index : Int) -> JsValue =
  #| (self, index) => self[index]
