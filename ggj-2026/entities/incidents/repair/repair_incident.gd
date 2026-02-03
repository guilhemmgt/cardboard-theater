@tool
extends Incident
class_name RepairIncident

@onready var area: Area3D = $Area3D
@onready var collisionShape: CollisionShape3D = $Area3D/CollisionShape3D
@export var clicks_required: int = 1
var clicks_done: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var tween: Tween
@export var failed_distance: float = 0.1

func _ready() -> void:
	super._ready()
	area.input_event.connect(on_click)
	collisionShape.disabled = true
	blocking = false

func activate(time: float):
	super.activate(time)
	clicks_done = 0
	collisionShape.disabled = false
	print("[repair] Activated on: ", name)
	animation_player.play("tremblement")
	
func deactivate(success: bool):
	collisionShape.disabled = true
	super.deactivate(success)
	if success:
		print("[repair] Resolved on: ", name)
		animation_player.stop()
	else:
		print("[repair] Failed on: ", name)
		var angle: int = 5
		var time_oscillation: float = 0.08
		animation_player.stop()
		tween = get_tree().create_tween()
		tween.tween_property(self, "position", self.position - Vector3(0, failed_distance, 0), 1.0)
		#tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CIRC)
		for i in range(5):
			tween.chain().tween_property(self, "rotation_degrees", self.rotation_degrees + Vector3(0, 0, angle), time_oscillation)
			tween.chain().tween_property(self, "rotation_degrees", self.rotation_degrees + Vector3(0, 0, -angle), time_oscillation)
		tween.play()

func on_click(_camera: Node,
			  event: InputEvent,
			  _event_position: Vector3,
			  _normal: Vector3,
			  _shape_idx: int):
	if (event.is_action_pressed('click')):
		print("coucou")
		clicks_done += 1
		if clicks_done >= clicks_required:
			deactivate(true)
