extends Node

const MOUSE_IDLE = preload("uid://cv8er5i4lebj2")
const MOUSE_ACTION = preload("uid://djb7775gil4aa")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Input.set_custom_mouse_cursor(MOUSE_ACTION)
	if event.is_action_released("click"):
		Input.set_custom_mouse_cursor(MOUSE_IDLE)
