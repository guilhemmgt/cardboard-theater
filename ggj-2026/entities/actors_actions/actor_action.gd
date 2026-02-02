@tool
class_name ActorAction
extends Resource

enum ActionType {
	MOVE,
	ANIM
}

@export_node_path("Actor") var actor_node_path: NodePath

@export var action_type: ActionType = ActionType.MOVE:
	set(value):
		action_type = value
		notify_property_list_changed()

var target_plan_id: int = 1
var target_node_id: int = 0
var move_duration: float = 1.0

var anim_name: String = ""
var anim_duration: float = 1.0

func _get_property_list() -> Array:
	var props: Array = []

	if action_type == ActionType.MOVE:
		props.append({
			"name": "target_plan_id",
			"type": TYPE_INT
		})
		props.append({
			"name": "target_node_id",
			"type": TYPE_INT
		})
		props.append({
			"name": "move_duration",
			"type": TYPE_FLOAT
		})

	if action_type == ActionType.ANIM:
		props.append({
			"name": "anim_name",
			"type": TYPE_STRING
		})
		props.append({
			"name": "anim_duration",
			"type": TYPE_FLOAT
		})

	return props
