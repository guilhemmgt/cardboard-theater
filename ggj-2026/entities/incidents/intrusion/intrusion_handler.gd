extends MeshInstance3D

@onready var intrusion_incident: IntrusionIncident 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child and child is IntrusionIncident:
			intrusion_incident = child as IntrusionIncident
			break

	# events setup
	print("[intrusion] Ready on: ", name, " - IntrusionIncident: ", intrusion_incident)
	intrusion_incident.activated.connect(_on_incident_activated)
	intrusion_incident.failed.connect(_on_incident_failed)
	intrusion_incident.resolved.connect(_on_incident_resolved)
	
func _on_incident_activated(_blocking: bool) -> void:
	print("[intrusion] Activated on: ", name)

func _on_incident_failed() -> void:
	print("[intrusion] Failed on: ", name)

func _on_incident_resolved() -> void:
	print("[intrusion] Resolved on: ", name)
