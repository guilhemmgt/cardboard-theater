extends Node3D
class_name Spectator

@export var anim: AnimationPlayer
@export var sprite_bubble : AnimatedSprite3D
@export var anim_bubble: AnimationPlayer

func _ready() -> void:
	react(["empty","joy","sad","angry"].pick_random())
	await get_tree().create_timer(randf_range(0,5)).timeout
	anim.play("idle")

func react(reaction:String):
	anim_bubble.play("react")
	match reaction:
		"empty":
			sprite_bubble.frame = 0
		"joy":
			sprite_bubble.frame = 1
		"sad":
			sprite_bubble.frame = 2
		"angry":
			sprite_bubble.frame= 3
	
