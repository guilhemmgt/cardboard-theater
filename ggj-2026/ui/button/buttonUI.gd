@tool
extends MeshInstance3D
class_name ButtonUI

signal button_clicked

@export var _area: Area3D
@export var _label: Label3D
@export var text: String

var random_offset: float

var _is_hover: bool = false

func _ready() -> void:
	_area.input_event.connect(_on_click)
	_label.text = text

func turn_with_elasticity(duration: float, degrees: float = 2.0) -> void:
	var tween: Tween = create_tween()
	# + ou -1
	var sign_rand: int = -1 if randi() % 2 == 0 else 1
	degrees *= sign_rand
	tween.tween_property(self, "rotation_degrees:x", rotation_degrees.x + degrees, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func reset_with_elasticity(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 0.0, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_area_3d_mouse_entered() -> void:
	random_offset = randf_range(-0.2, 0.2)
	turn_with_elasticity(0.5, 3.0 + random_offset)
	_is_hover = true
func _on_area_3d_mouse_exited() -> void:
	reset_with_elasticity(0.5)
	_is_hover = false


func _on_click(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_released("click"):
		button_clicked.emit()
