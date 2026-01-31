extends Node
class_name Orchestrator

signal points_ready
signal pause_state_changed(is_paused: bool)

@onready var plan1: Node = $Plan1
@onready var plan2: Node = $Plan2
@onready var plan3: Node = $Plan3

var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

# Système de pause
var is_paused: bool = false
var registered_actors: Array[ActorController] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points_plan1 = plan1.get_children()
	points_plan2 = plan2.get_children()
	points_plan3 = plan3.get_children()
	# Émettre le signal pour notifier que les points sont prêts
	points_ready.emit()

	await get_tree().create_timer(2.0).timeout
	#test pause resume
	#play turn



func get_plan_points(plan_number: int) -> Array:
	match plan_number:
		1:
			return points_plan1
		2:
			return points_plan2
		3:
			return points_plan3
		_:
			return []

func register_actor(actor: ActorController) -> void:
	if actor not in registered_actors:
		registered_actors.append(actor)
		print("ActorController registered: %s" % actor.name)

func unregister_actor(actor: ActorController) -> void:
	if actor in registered_actors:
		registered_actors.erase(actor)
		print("ActorController unregistered: %s" % actor.name)

func pause_all_actors() -> void:
	is_paused = true
	print("Pausing all actors")
	for actor in registered_actors:
		if is_instance_valid(actor):
			actor.set_paused(true)
	pause_state_changed.emit(true)

func resume_all_actors() -> void:
	is_paused = false
	print("Resuming all actors")
	for actor in registered_actors:
		if is_instance_valid(actor):
			actor.set_paused(false)
	pause_state_changed.emit(false)

func toggle_pause() -> void:
	if is_paused:
		resume_all_actors()
	else:
		pause_all_actors()

func get_pause_state() -> bool:
	return is_paused
