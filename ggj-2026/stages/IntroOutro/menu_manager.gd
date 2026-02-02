extends Node3D


func _on_play_button_clicked() -> void:
	pass # Replace with function body.


func _on_quit_button_clicked() -> void:
	get_tree().quit()


func _on_credits_button_clicked() -> void:
	push_warning("no credits menu")
