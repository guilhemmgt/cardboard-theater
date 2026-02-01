extends MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_herse_resolved() -> void:
	animation_player.play("activate_herse")
