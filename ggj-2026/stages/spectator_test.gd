extends Node3D

@onready var spectator: Spectator = $Spectator
@onready var spectator_2: Spectator = $Spectator2
@onready var spectator_3: Spectator = $Spectator3

func _ready() -> void:
	spectator.react("joy")
	await get_tree().create_timer(1).timeout
	spectator.react("empty")
	spectator_2.react("sad")
	await get_tree().create_timer(1).timeout
	spectator_2.react("empty")
	spectator_3.react("angry")
