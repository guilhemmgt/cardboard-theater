@tool
extends MeshInstance3D
class_name ButtonUI

signal button_clicked
@onready var carton_particle: GPUParticles3D = $CartonParticle
@onready var spot_light_3d: SpotLight3D = $SpotLight3D

@export var _area: StaticBody3D
@export var _label: Label3D
@export var text: String
@export var mouse_speed_threshold: float = 5
var random_offset: float

var _is_hover: bool = false
var _clicking : bool = false

var mouse_speed: float = 0.0
var mouse_pos: Vector2

func _ready() -> void:
	_area.input_event.connect(_on_click)
	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	SignalBus.tomato_hit.connect(func(body: Node3D, pos: Vector3):
		if body == _area:
			button_clicked.emit()
	)
	_label.text = text

func _process(_delta: float) -> void:
	var current_mouse_pos = get_viewport().get_mouse_position()
	mouse_speed = (current_mouse_pos - mouse_pos).length()
	mouse_pos = current_mouse_pos
	if mouse_speed < mouse_speed_threshold:
		carton_particle.emitting = false


func turn_with_elasticity(duration: float, degrees: float = 2.0) -> void:
	var tween: Tween = create_tween()
	# + ou -1
	var sign_rand: int = -1 if randi() % 2 == 0 else 1
	degrees *= sign_rand
	tween.tween_property(self, "rotation_degrees:x", rotation_degrees.x + degrees, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func reset_with_elasticity(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation_degrees:x", 0.0, duration).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	random_offset = randf_range(-0.2, 0.2)
	turn_with_elasticity(0.5, 3.0 + random_offset)
	_is_hover = true
	spot_light_3d.visible = true
	
func _on_mouse_exited() -> void:
	reset_with_elasticity(0.5)
	_is_hover = false
	carton_particle.emitting = false
	spot_light_3d.visible = false
	
func _on_particle_countdown_timeout() -> void:
	carton_particle.emitting = false
	
func _on_start_particle_countdown_timeout() -> void:
	carton_particle.emitting = true

func _on_click(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		_clicking = true
	if _clicking:
		if event.is_action_released("click"):
			_clicking = false
			button_clicked.emit()
	if _is_hover and event is InputEventMouseMotion and mouse_speed > mouse_speed_threshold:
		carton_particle.emitting = true
		#Project mouse onto the plane of the button
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var camerav : Camera3D = get_viewport().get_camera_3d()
		
		var ray_origin := camerav.project_ray_origin(mouse_pos)
		var ray_dir := camerav.project_ray_normal(mouse_pos)
		var ray_end := ray_origin + ray_dir * 1000.0

		var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
		)
		query.collide_with_areas = true

		var result := get_world_3d().direct_space_state.intersect_ray(query)
		if result:
			carton_particle.global_position = result.position - ray_dir * 0.5
