extends Node
class_name Orchestrator

@onready var game_over: Node3D = $"../Scene/GameOver"
@export var incidents_manager: Node

@export var actor_manager: ActorManager

# Pause system
var is_paused: bool = false
var incidents_nodes: Array[Incident] = []
var is_point_ready: bool = false

func _ready() -> void:

	for incident in incidents_manager.get_children():
		if incident is Incident:
			incidents_nodes.append(incident)

	for incident in incidents_nodes:
		incident.resolved.connect(_on_event_success)
		incident.failed.connect(_on_event_failure)
		incident.activated.connect(_on_incident_activated)

func get_pause_state() -> bool:
	return is_paused

func _on_event_success() -> void:
	print("Event resolved successfully")
	if is_paused:
		actor_manager.resume_all_actors()

func _on_event_failure() -> void:
	print("Event failed - game over")
	await get_tree().create_timer(2.0).timeout
	var tween = create_tween()
	tween.tween_property(game_over, "global_position:y", 2.203, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_incident_activated(blocking: bool) -> void:
	if blocking:
		actor_manager.pause_all_actors()
		print("Blocking incident activated")
	else:
		print("Non-blocking incident activated")
