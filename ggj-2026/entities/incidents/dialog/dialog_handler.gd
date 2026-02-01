extends MeshInstance3D

@onready var dialog_incident: DialogIncident 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child and child is DialogIncident:
			dialog_incident = child as DialogIncident
			break

	# events setup
	print("[dialog] Ready on: ", name, " - DialogIncident: ", dialog_incident)
	dialog_incident.activated.connect(_on_incident_activated)
	dialog_incident.failed.connect(_on_incident_failed)
	dialog_incident.resolved.connect(_on_incident_resolved)
	
func _on_incident_activated(_blocking: bool) -> void:
	print("[dialog] Activated on: ", name)

func _on_incident_failed() -> void:
	print("[dialog] Failed on: ", name)

func _on_incident_resolved() -> void:
	print("[dialog] Resolved on: ", name)
