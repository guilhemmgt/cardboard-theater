extends MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var anim_name: String # sus
@onready var activation_incident: ActivationIncident

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child and child is DialogIncident:
			activation_incident = child as ActivationIncident
			break

	# events setup
	print("[activation] Ready on: ", name, " - ActivationHandler: ", activation_incident)
	activation_incident.activated.connect(_on_incident_activated)
	activation_incident.failed.connect(_on_incident_failed)
	activation_incident.resolved.connect(_on_incident_resolved)
	
func _on_incident_activated(_blocking: bool) -> void:
	print("[activation] Activated on: ", name)

func _on_incident_failed() -> void:
	print("[activation] Failed on: ", name)

func _on_incident_resolved() -> void:
	print("[activation] Resolved on: ", name)
	if anim_name == null:
		push_error("no anim")
		return
	animation_player.play(anim_name)
