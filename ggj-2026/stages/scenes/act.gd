extends Node3D
class_name Act

@export var anim : AnimationPlayer

func start_act() -> void:
	if anim:
		anim.play("scene")
