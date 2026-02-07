extends Node3D

const MENU = preload("uid://o82m05ah8w86")

@export var scenes_parent : Node3D
@export var theater : Theater
var _menu : MenuManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu()

func menu():
	_menu = MENU.instantiate()
	scenes_parent.add_child(_menu)
	_menu.play_button_clicked.connect(play)

func play():
	if (_menu):
		_menu.queue_free()
	theater.make_spectators_enter()
	
