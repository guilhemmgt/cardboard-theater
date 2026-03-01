extends Node

var theater: Theater

func _ready() -> void:
	theater = _find_theater()
	SignalBus.ask_to_move.connect(move_to_marker)
	SignalBus.ask_to_set_position.connect(set_position_to_marker)

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

func set_position_to_marker(node: Node3D, plan: int, pos: int) -> void:
	var marker: Vector3 = theater.get_marker(plan, pos)
	node.global_position.x = marker.x
	node.global_position.z = marker.z

func _get_all_nodes(root: Node) -> Array[Node]:
	var result: Array[Node] = [root]
	for child in root.get_children():
		result.append_array(_get_all_nodes(child))
	return result
	
func _find_theater() -> Theater:
	for node in _get_all_nodes(get_tree().root):
		if node is Theater:
			return node as Theater
	return null
