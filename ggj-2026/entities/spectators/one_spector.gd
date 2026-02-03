extends Node3D
class_name Spectator

@export var anim: AnimationPlayer
@export var sprite_bubble : AnimatedSprite3D
@export var anim_bubble: AnimationPlayer

func _ready() -> void:
	anim.play("idle", -1, randf_range(0.8, 1.2), bool(randi()%2))

func react(reaction:String):
	anim_bubble.play("react")
	match reaction:
		"empty":
			sprite_bubble.frame = 0
		"cow":
			sprite_bubble.frame = 1
		"guitar":
			sprite_bubble.frame = 2
		"angry":
			sprite_bubble.frame= 3
	
func leave():
	anim.play("leave")
