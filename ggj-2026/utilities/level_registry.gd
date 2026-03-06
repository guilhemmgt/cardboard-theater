## List of levels (scenes), to be instantiated in the theater.
@tool
extends Resource
class_name LevelRegistry


@export var _levels: Array[PackedScene] = []:
	set(value):
		_levels = value
		notify_property_list_changed()

var _default_level: PackedScene


## Get the default level
func get_default() -> PackedScene:
	return _default_level


## Get all levels
func get_all_levels() -> Array[PackedScene]:
	return _levels


# Below are shenanigans to have a cool "Default Level" dropdown behaviour

# the drop down menu needs a backing String field, but i dont want to expose this field, because it would risk breaking the UI.
# i could have a "private" field starting with an underscore...
# BUT godot is racist, and do not allow using _get_property_list with a property whose name starts with an underscore. :(
# so: there is no backing field, and it works by overriding _get and _set
# sorry

# backing field name
var _FIELD_LABEL = "default_level_name"
# backing field value when _default_level is null
var _NO_LEVEL_TEXT = "<no level selected>"

func _get_all_names() -> Array[String]:
	var res: Array[String] = []
	res.assign(_levels.filter(func(s): return s != null).map(_get_name))
	return res


func _get_name(scene: PackedScene) -> String:
	return scene.resource_path.get_file().get_basename()


func _get_by_name(name: String) -> PackedScene:
	var all: Array[PackedScene] = _levels.filter(func(scene: PackedScene): return scene != null && _get_name(scene) == name)
	return null if all.is_empty() else all[0]


func _get_first_non_null() -> PackedScene:
	var all: Array[PackedScene] = _levels.filter(func(scene: PackedScene): return scene != null)
	return null if all.is_empty() else all[0]


func _get_property_list():
	var names: Array[String] = _get_all_names()
	if (_default_level not in _levels or _default_level == null) && not _levels.is_empty():
		_default_level = _get_first_non_null()
	if _levels.is_empty():
		_default_level = null
	var keys_string = ",".join(names)
	var properties = []
	properties.append({
		"name": _FIELD_LABEL,
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": keys_string,
	})
	return properties


func _set(property, value):
	if property == _FIELD_LABEL && value is String:
		var value_string: String = value
		_default_level = _get_by_name(value_string)
		return true
	return false


func _get(property: StringName):
	if property == _FIELD_LABEL:
		if _default_level == null:
			return _NO_LEVEL_TEXT
		return _get_name(_default_level)
