extends MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var repair_incident: RepairIncident = $RepairIncident

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	repair_incident.activated.connect(_on_repair_incident_activated)
	repair_incident.resolved.connect(func():
		animation_player.stop()
	)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_repair_incident_activated() -> void:
	animation_player.play("tremblement")
