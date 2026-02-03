@tool
extends MeshInstance3D
class_name ButtonUI

signal button_clicked
@onready var carton_particle: GPUParticles3D = $CartonParticle

@export var _area: Area3D
@export var _label: Label3D
@export var text: String

var random_offset: float

var _is_hover: bool = false
var particle_countdown: Timer
func _ready() -> void:
	_area.input_event.connect(_on_click)
	_label.text = text
	particle_countdown = Timer.new()
	particle_countdown.one_shot = true
	particle_countdown.timeout.connect(_on_particle_countdown_timeout)
	add_child(particle_countdown)

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
	carton_particle.emitting = false
	
func _on_particle_countdown_timeout() -> void:
	carton_particle.emitting = false
	
func _on_click(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_released("click"):
		button_clicked.emit()
	if _is_hover and event is InputEventMouseMotion:
		carton_particle.emitting = true
		particle_countdown.start(0.02)
		#Project mouse onto the plane of the button
		var mouse_pos = get_viewport().get_mouse_position()
		var camerav = get_viewport().get_camera_3d()
		
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
