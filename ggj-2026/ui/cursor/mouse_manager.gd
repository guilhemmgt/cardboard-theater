extends Node

const MOUSE_IDLE = preload("uid://cv8er5i4lebj2")
const MOUSE_ACTION = preload("uid://djb7775gil4aa")
const MOUSE_TOMATO = preload("uid://bw3jfo8dydjdb")

@export var theater : Theater

func _ready() -> void:
	if (theater):
		theater.tomato_basket.drag.connect(drag)
	else:
		push_warning("No theater given in MouseManagerr : could not find TomatoBasket")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Input.set_custom_mouse_cursor(MOUSE_ACTION)
	if event.is_action_released("click"):
		Input.set_custom_mouse_cursor(MOUSE_IDLE)

func drag(is_dragging:bool):
	if is_dragging:
		Input.set_custom_mouse_cursor(MOUSE_TOMATO)
	else :
		Input.set_custom_mouse_cursor(MOUSE_IDLE)
