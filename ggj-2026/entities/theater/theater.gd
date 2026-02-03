extends Node
class_name Theater

# 3 plans (depth)
# 6 positions (width)
# 3x6=18 markers

@export var plans: Node

var _markers: Array[Array]

func _ready() -> void:
	for plan in plans.get_children():
		var plan_positions: Array = []
		for pos: Marker3D in plan.get_children():
			plan_positions.append(pos.global_position)
		_markers.append(plan_positions)

func get_marker(plan: int, pos: int) -> Vector3:
	return _markers[plan][pos]
