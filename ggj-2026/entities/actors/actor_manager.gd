extends Node3D
class_name ActorManager

var actors: Array[Actor] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Actor:
			actors.append(child as Actor)

func pause_all_actors() -> void:
	for actor in actors:
		#pause actor timer
		if actor.animation_timer and actor.animation_timer.is_stopped() == false:
			actor.animation_timer.stop()
		else:
			pass
func resume_all_actors() -> void:
	for actor in actors:
		if actor.animation_timer and actor.animation_timer.is_stopped() == true:
			actor.animation_timer.start()
		else:
			pass


func get_actors() -> Array:
	return actors
