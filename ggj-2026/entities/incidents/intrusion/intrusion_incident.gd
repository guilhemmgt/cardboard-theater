extends Incident
class_name IntrusionIncident

@export var area: Area3D
@export var collisionShape: CollisionShape3D

func _ready() -> void:
	super._ready()

func activate(time: float):
	super.activate(time)
	collisionShape.disabled = false

func deactivate(success: bool):
	super.deactivate(success)
	collisionShape.disabled = true
