extends Node3D
class_name MenuManager

signal play_button_clicked

@export var camera : Camera3D
@export var play_button : ButtonUI
@export var credits_button : ButtonUI
@export var quit_button : ButtonUI

func _ready() -> void:
	SignalBus.init_curtains.emit(false)
	SignalBus.toggle_curtains.emit()
	play_button.button_clicked.connect(_on_play_button_clicked)
	credits_button.button_clicked.connect(_on_credits_button_clicked)
	quit_button.button_clicked.connect(_on_quit_button_clicked)
	
func _on_play_button_clicked() -> void:
	play_button_clicked.emit()


func _on_quit_button_clicked() -> void:
	SignalBus.toggle_curtains.emit()
	await SignalBus.curtains_closed
	get_tree().quit()


func _on_credits_button_clicked() -> void:
	push_warning("no credits menu")
