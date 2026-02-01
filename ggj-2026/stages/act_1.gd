extends Node3D
const WIN = preload("uid://qwqb057pjk8d")


func _on_act_1_animation_finished(anim_name: StringName) -> void:
	if anim_name == "scene0":
		print("WIIIIIIN")
		var win :Win= WIN.instantiate()
		add_child(win)
		win.play()
