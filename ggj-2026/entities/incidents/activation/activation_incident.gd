@tool
extends Incident
class_name ActivationIncident

@export var shape: Shape3D
@export var area: Area3D
@export var collisionShape: CollisionShape3D
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
	collisionShape.disabled = true
	area.input_event.connect(on_click)

func activate(time: float):
	super.activate(time)
	collisionShape.disabled = false
	
func deactivate(success: bool):
	collisionShape.disabled = true
	super.deactivate(success)

func on_click(_camera: Node, 
			  event: InputEvent, 
			  _event_position: Vector3, 
			  _normal: Vector3, 
			  _shape_idx: int):
	if (event.is_action_pressed('click')):
		deactivate(true)
