extends Node3D
class_name Win

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play():
	animation_player.play("win")
