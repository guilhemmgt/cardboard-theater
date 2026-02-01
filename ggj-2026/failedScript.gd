extends MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var repair_incident: RepairIncident 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child and child is RepairIncident:
			repair_incident = child as RepairIncident
			break

	print("[failedScript] Ready on: ", name, " - RepairIncident: ", repair_incident)
	repair_incident.activated.connect(_on_repair_incident_activated)
	repair_incident.resolved.connect(func():
		print("[failedScript] Resolved on: ", name)
		animation_player.stop()
	)


func _on_repair_incident_activated(_blocking: bool) -> void:
	print("[failedScript] Activated on: ", name, " - Playing tremblement on AnimationPlayer: ", animation_player)
	animation_player.play("tremblement")
