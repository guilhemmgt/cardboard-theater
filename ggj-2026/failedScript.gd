extends MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var repair_incident: RepairIncident 
var tween: Tween
@export var failed_distance: float

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
	repair_incident.failed.connect(_on_repair_failed)


func _on_repair_incident_activated(_blocking: bool) -> void:
	print("[failedScript] Activated on: ", name, " - Playing tremblement on AnimationPlayer: ", animation_player)
	animation_player.play("tremblement")

func _on_incident_failed() -> void:
	print("[repair] Failed on: ", name)
	var angle : int = 5
	var time_oscillation : float = 0.08
	animation_player.stop()
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", self.position - Vector3(0,failed_distance,0), 1.0)
	#tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	for i in range(5):
		tween.chain().tween_property(self, "rotation_degrees", self.rotation_degrees + Vector3(0,0,angle), time_oscillation)
		tween.chain().tween_property(self, "rotation_degrees", self.rotation_degrees + Vector3(0,0,-angle), time_oscillation)
	tween.play()

func _on_incident_resolved() -> void:
	print("[repair] Resolved on: ", name)
	animation_player.stop()
