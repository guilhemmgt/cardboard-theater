extends MeshInstance3D
class_name ButtonUI


var random_offset: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func turn_with_elasticity(duration: float,degrees: float = 2.0) -> void:
	var tween: Tween = create_tween()
	# + ou -1
	var sign_rand: int = -1 if randi() % 2 == 0 else 1
	degrees *= sign_rand
	tween.tween_property(self, "rotation_degrees:x", rotation_degrees.x + degrees, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func reset_with_elasticity(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 0.0, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_area_3d_mouse_entered() -> void:
	random_offset = randf_range(-0.2,0.2)
	turn_with_elasticity(0.5,3.0+random_offset)



func _on_area_3d_mouse_exited() -> void:
	reset_with_elasticity(0.5)
