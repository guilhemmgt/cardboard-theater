extends Node
class_name Orchestrator

signal points_ready
signal pause_state_changed(is_paused: bool)
@onready var error_event: Timer = $"../ErrorEvent"

@onready var plan1: Node = $Plan1
@onready var plan2: Node = $Plan2
@onready var plan3: Node = $Plan3

var points_plan1: Array = []
var points_plan2: Array = []
var points_plan3: Array = []

@onready var arbre: RepairIncident = $"../arbre/RepairIncident"
@onready var nuage_2: RepairIncident = $"../nuage2/RepairIncident"


# Système de pause
var is_paused: bool = false
var registered_actors: Array[ActorController] = []


var decors_nodes: Array[RepairIncident] = []

var is_point_ready:bool=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points_plan1 = plan1.get_children()
	print(points_plan1)
	points_plan2 = plan2.get_children()
	points_plan3 = plan3.get_children()
	print("emit")
	# Émettre le signal pour notifier que les points sont prêts
	points_ready.emit()
	is_point_ready=true


	error_event.wait_time = randf_range(3.0, 8.0)
	error_event.start()

	print("J'appends :",arbre,nuage_2)
	#decors_nodes.append(arbre)
	decors_nodes.append(nuage_2)
	print("Decors nodes registered:")
	print("decors_nodes:",decors_nodes)

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
	print("Error event triggered - toggling pause state")
	print("decors_nodes size: ", decors_nodes.size())
	print("decors_nodes content: ", decors_nodes)
	for i in range(decors_nodes.size()):
		print("  [", i, "] = ", decors_nodes[i], " parent: ", decors_nodes[i].get_parent().name if decors_nodes[i].get_parent() else "null")
	#vhoose random decor to trigger event
	var random_index = randi() % decors_nodes.size()
	print("Random index: ", random_index)
	var random_decor: RepairIncident = decors_nodes[random_index]
	print("Selected decor: ", random_decor, " parent: ", random_decor.get_parent().name if random_decor.get_parent() else "null")
	random_decor.activate(5.0)

func _on_event_success() -> void:
	print("Event success - resuming all actors")
	
func _on_event_failure() -> void:
	print("Vous avez échoué l'événement !")
