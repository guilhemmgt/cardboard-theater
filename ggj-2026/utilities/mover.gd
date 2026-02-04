extends Node

@export var theater: Theater

## Move a Node3D to a plan and position (moves both X and Y).
func move_to_marker(node: Node3D, duration: float, plan: int, pos: int):
	var marker: Vector3 = theater.get_marker(plan, pos)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	var rotation_tween: Tween = create_tween()
	if node is IntrusionIncident:
		var intrusion: IntrusionIncident = node as IntrusionIncident

		if marker.x < node.global_position.x:
			rotation_tween.tween_property(node, "global_rotation:y", PI, 0.3)
			intrusion.is_left_oriented = false
		elif marker.x > node.global_position.x:
			rotation_tween.tween_property(node, "global_rotation:y", 0, 0.3)
			intrusion.is_left_oriented = true

	tween.tween_property(node, "global_position:x", marker.x, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "global_position:z", marker.z, duration)
	rotation_tween.play()
	tween.play()
func _ready() -> void:
	SignalBus.ask_to_move.connect(move_to_marker)
