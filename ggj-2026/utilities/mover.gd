extends Node

@export var theater: Theater

## Move a Node3D to a plan and position (moves both X and Y).
func move_to_marker(node: Node3D, duration: float, plan: int, pos: int):
	var marker: Vector3 = theater.get_marker(plan, pos)
	var tween: Tween = create_tween()
	tween.tween_property(node, "global_position:x", marker.x, duration)
	tween.tween_property(node, "global_position:y", marker.y, duration)
