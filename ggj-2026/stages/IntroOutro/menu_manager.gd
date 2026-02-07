extends Node3D

@export var camera : Camera3D
@export var play_button : ButtonUI
@export var credits_button : ButtonUI
@export var quit_button : ButtonUI

func _ready() -> void:
	GeneralNodes.set_camera(camera)
	play_button.button_clicked.connect(_on_play_button_clicked)
	credits_button.button_clicked.connect(_on_credits_button_clicked)
	quit_button.button_clicked.connect(_on_quit_button_clicked)
	
func _on_play_button_clicked() -> void:
	pass # Replace with function body.


func _on_quit_button_clicked() -> void:
	get_tree().quit()


func _on_credits_button_clicked() -> void:
	push_warning("no credits menu")
