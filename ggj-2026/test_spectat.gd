extends Node3D
@onready var spectators: SpectatorManager = $Spectators

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	for i in range(3):
		spectators.react_to_intruder(["cow", "guitar", "angry"].pick_random())
		await get_tree().create_timer(2).timeout
	for i in range(3):
		spectators.update_life(2-i, 3)
		await get_tree().create_timer(4).timeout  
	get_tree().quit()
