extends Node
class_name Orchestrator

signal points_ready
signal pause_state_changed(is_paused: bool)

@onready var game_over: Node3D = $"../GameOver"
@onready var plan1: Node = $Plan1
@onready var plan2: Node = $Plan2
@onready var plan3: Node = $Plan3
@onready var incidents_manager: Node = $"../IncidentsManager"


var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

# Pause system
var is_paused: bool = false
var registered_actors: Array[ActorController] = []
var incidents_nodes: Array[Incident] = []
var is_point_ready: bool = false
func _ready() -> void:
	# Initialize plan points
	points_plan1 = plan1.get_children()
	points_plan2 = plan2.get_children()
	points_plan3 = plan3.get_children()
	
	# Emit signal to notify that points are ready
	points_ready.emit()
	is_point_ready = true
	
	# Find all RepairIncident nodes in incidents manager
	for child in incidents_manager.get_children():
		for incident in child.get_children():
			if incident and incident is Incident:
				var decor: Incident = incident as Incident
				incidents_nodes.append(decor)
	
	
	# Connect signals for all incident nodes
	print("Incidents found: %d" % incidents_nodes.size())
	for incident in incidents_nodes:
		incident.resolved.connect(_on_event_success)
		incident.failed.connect(_on_event_failure)
		incident.activated.connect(_on_incident_activated)
		

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

func _on_event_success() -> void:
	print("Event resolved successfully")
	if is_paused:
		resume_all_actors()

func _on_event_failure() -> void:
	print("Event failed - game over")
	await get_tree().create_timer(2.0).timeout
	game_over.visible = true

func _on_incident_activated(blocking: bool) -> void:
	if blocking:
		pause_all_actors()
		print("Blocking incident activated")
	else:
		print("Non-blocking incident activated")
