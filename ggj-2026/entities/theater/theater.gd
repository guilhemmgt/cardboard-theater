@tool
extends Node
class_name Theater

# 3 plans (depth)
# 6 positions (width)
# 3x6=18 markers

@export var plans: Node
@export var tomato_basket : TomatoBasket

@export var debug_curtains_node: Node

var _markers: Array[Array]

func _ready() -> void:
	for plan in plans.get_children():
		var plan_positions: Array = []
		for pos: Marker3D in plan.get_children():
			plan_positions.append(pos.global_position)
		_markers.append(plan_positions)

func get_marker(plan: int, pos: int) -> Vector3:
	return _markers[plan][pos]

@export var debug_curtains: bool:
	set(value):
		debug_curtains = value
		debug_curtains_node.call('debug_set_curtains', value)
