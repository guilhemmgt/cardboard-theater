extends Node
class_name Orchestrator

signal points_ready

@onready var game_over: Node3D = $"../GameOver"
@onready var plan1: Node = $Plan1
@onready var plan2: Node = $Plan2
@onready var plan3: Node = $Plan3
@onready var incidents_manager: Node = $"../IncidentsManager"
@export var animation_p : AnimationPlayer 

@export var action_array: Array[ActorAction] = []

var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

# Pause system
var is_paused: bool = false
var registered_actors: Array[Actor] = []
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
	

	for incident in incidents_nodes:
		incident.resolved.connect(_on_event_success)
		incident.failed.connect(_on_event_failure)
		incident.activated.connect(_on_incident_activated)

	read_actions()
		

func read_actions() -> void:
	for action in action_array:
		print("Action: %s" % action.action_type)
		print("Parameters: %s" % action)

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

func register_actor(actor: Actor) -> void:
	if actor not in registered_actors:
		registered_actors.append(actor)
		print("ActorController registered: %s" % actor.name)

func unregister_actor(actor: Actor) -> void:
	if actor in registered_actors:
		registered_actors.erase(actor)
		print("ActorController unregistered: %s" % actor.name)

func get_pause_state() -> bool:
	return is_paused

func _on_event_success() -> void:
	print("Event resolved successfully")
	if is_paused:
		animation_p.play()

func _on_event_failure() -> void:
	print("Event failed - game over")
	await get_tree().create_timer(2.0).timeout
	var tween = create_tween()
	tween.tween_property(game_over, "global_position:y", 2.203, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_incident_activated(blocking: bool) -> void:
	if blocking:
		animation_p.pause()
		print("Blocking incident activated")
	else:
		print("Non-blocking incident activated")
