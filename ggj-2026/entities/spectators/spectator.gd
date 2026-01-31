extends Node3D
class_name Spectator

@export var anim : AnimatedSprite3D

func react(reaction:String):
	match reaction:
		"empty":
			anim.frame = 0
		"joy":
			anim.frame = 1
		"sad":
			anim.frame = 2
		"angry":
			anim.frame= 3
