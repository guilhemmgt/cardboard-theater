@tool
extends Incident
class_name RepairIncident

@export var area: Area3D
@export var collisionShape: CollisionShape3D
@export var clicks_required: int
@export var shape : Shape3D
var clicks_done : int

@export_tool_button("Apply Shape") var apply_shape_button = apply_shape

func apply_shape() -> void:
	if collisionShape:
		collisionShape.shape = shape
		print("shape applied")
	else :
		print("no collision shape")

func _ready() -> void:
	super._ready()
	collisionShape.shape = shape
	area.input_event.connect(on_click)
	collisionShape.disabled=true

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
