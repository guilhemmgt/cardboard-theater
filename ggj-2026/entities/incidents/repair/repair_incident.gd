extends Incident
class_name RepairIncident

@export var area: Area3D
@export var collisionShape: CollisionShape3D
@export var clicks_required: int
var clicks_done : int

func _ready() -> void:
	super._ready()
	area.input_event.connect(on_click)

func activate(time: float):
	super.activate(time)
	clicks_done = 0
	collisionShape.disabled = false
	
func deactivate(success: bool):
	super.deactivate(success)
	collisionShape.disabled = true

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
