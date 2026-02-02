extends Node3D

var actors: Array[Actor] = []
@onready var orchestrator: Orchestrator = $"../Orchestrator"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Actor:
			actors.append(child as Actor)
	if not orchestrator.is_point_ready:
		await orchestrator.points_ready

	points_plan1 = orchestrator.get_plan_points(1)
	points_plan2 = orchestrator.get_plan_points(2)
	points_plan3 = orchestrator.get_plan_points(3)

@export var plan_number: int = 3
var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

func move_actor(actor_name: String, target_plan_id: int, target_node_id: int, move_duration: float) -> void:
	for actor in actors:
		if actor.name == actor_name:
			var global_coordinates: Vector3 = get_target_global_position_by_id(target_plan_id, target_node_id)
			actor.move_to_coordinates(global_coordinates,move_duration)
			return
	push_error("Actor with name %s not found." % actor_name)

func anim_actor(actor_name: String, anim_name: String, anim_duration: float) -> void:
	for actor in actors:
		if actor.name == actor_name:
			actor.anim(anim_name, anim_duration)
			return
	push_error("Actor with name %s not found." % actor_name)

func get_target_global_position_by_id(target_plan_id: int, target_node_id: int) -> Vector3:
	var target_global_position: Vector3 = Vector3.ZERO
	match target_plan_id:
		1:
			if target_node_id >= 0 and target_node_id < points_plan1.size():
				target_global_position = points_plan1[target_node_id].global_position
		2:
			if target_node_id >= 0 and target_node_id < points_plan2.size():
				target_global_position = points_plan2[target_node_id].global_position
		3:
			if target_node_id >= 0 and target_node_id < points_plan3.size():
				target_global_position = points_plan3[target_node_id].global_position
	return target_global_position

func pause_all_actors() -> void:
	for actor in actors:
		#pause actor timer
		if actor.animation_timer and actor.animation_timer.is_stopped() == false:
			actor.animation_timer.stop()
		else:
			pass
