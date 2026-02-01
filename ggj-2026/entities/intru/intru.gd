extends Node
class_name Intru

@onready var actor_node: Node = get_parent()
@onready var actor_animation_player: AnimationPlayer = $AnimationPlayer
var orchestrator: Orchestrator

var is_actor_moving: bool = false
var plan_number: int = 1
var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

var animation_timer: Timer

func init() -> void:
	if not orchestrator.is_point_ready:
		await orchestrator.points_ready
	points_plan1 = orchestrator.get_plan_points(1)
	points_plan2 = orchestrator.get_plan_points(2)
	points_plan3 = orchestrator.get_plan_points(3)

func move(target_node_id: int, move_duration: float) -> void:
	is_actor_moving = true
	var current_tween = create_tween()
	var target_global_position: Vector3 = Vector3.ZERO
	target_global_position = get_target_global_position_by_id(target_node_id)
	current_tween.tween_property(actor_node, "global_position", target_global_position, move_duration)
	current_tween.tween_callback(func(): is_actor_moving = false)

func anim(anim_name: String, anim_duration: float) -> void:
	actor_animation_player.play(anim_name)
	animation_timer = Timer.new()
	animation_timer.one_shot = true
	animation_timer.wait_time = anim_duration
	animation_timer.timeout.connect(on_animation_timer_timeout)

func plan_change(new_plan_number: int,new_plan_node_id :int,duration:float) -> void:
	plan_number = new_plan_number
	move(new_plan_node_id, duration)

func get_target_global_position_by_id(target_node_id: int) -> Vector3:
	var target_global_position: Vector3 = Vector3.ZERO
	match plan_number:
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

func on_animation_timer_timeout() -> void:
	actor_animation_player.stop()
