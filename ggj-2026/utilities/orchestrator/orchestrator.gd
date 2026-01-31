extends Node
class_name Orchestrator

signal points_ready
signal pause_state_changed(is_paused: bool)

@onready var error_event: Timer = $"../ErrorEvent"
@onready var game_over: Node3D = $"../GameOver"
@onready var plan1: Node = $Plan1
@onready var plan2: Node = $Plan2
@onready var plan3: Node = $Plan3
@onready var reparable_env: Node = $"../ReparableEnv"

var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

# Pause system
var is_paused: bool = false
var registered_actors: Array[ActorController] = []
var decors_nodes: Array[RepairIncident] = []
var is_point_ready: bool = false
func _ready() -> void:
	# Initialize plan points
	points_plan1 = plan1.get_children()
	points_plan2 = plan2.get_children()
	points_plan3 = plan3.get_children()
	
	# Emit signal to notify that points are ready
	points_ready.emit()
	is_point_ready = true
	
	# Start error event timer
	error_event.wait_time = randf_range(3.0, 8.0)
	error_event.start()
	
	# Find all RepairIncident nodes in reparable environment
	for child in reparable_env.get_children():
		var repair_incident = child.get_node_or_null("RepairIncident")
		if repair_incident and repair_incident is RepairIncident:
			var decor: RepairIncident = repair_incident as RepairIncident
			decors_nodes.append(decor)
	
	print("Registered decor nodes: ", decors_nodes.size())
	
	# Connect signals for all decor nodes
	for decor in decors_nodes:
		decor.resolved.connect(_on_event_success)
		decor.failed.connect(_on_event_failure)

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


func _on_error_event_timeout() -> void:
	print("Error event triggered")
	var rand_event_type = randi() % 2
	if rand_event_type == 0:
		random_decor_error_event()
	else : 
		pass


func random_decor_error_event() -> void:

	var random_index = randi() % decors_nodes.size()
	var random_decor: RepairIncident = decors_nodes[random_index]
	print("Activating decor at index: ", random_index)
	random_decor.activate(5.0)

func _on_event_success() -> void:
	print("Event resolved successfully")

func _on_event_failure() -> void:
	print("Event failed - game over")
	game_over.visible = true
