## Manages picking up / down and throwing tomatoes

extends Node3D
class_name TomatoBasket

@onready var camera: Camera3D

@export var tomato_scene: PackedScene
@export var area: Area3D
@export var raycast: RayCast3D

@export var tomato_speed: float
@export var tomato_peak_height_coef: float
@export var tomato_safety_overshoot_coef: float

var _aiming : bool
var _cursor_over_area : bool

func _ready():
	# if we click down on the basket, we start aiming
	area.input_event.connect(func(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
		if event.is_action_pressed('click'):
			start_aiming()
	)
	# detect if the cursor if over the basket
	area.mouse_entered.connect(func():
		_cursor_over_area = true
	)
	area.mouse_exited.connect(func():
		_cursor_over_area = false
	)
	# get a camera
	camera = await GeneralNodes.get_camera()


func start_aiming():
	_aiming = true
	SignalBus.tomato_picked.emit()
	
func stop_aiming():
	_aiming = false
	SignalBus.tomato_released.emit()
	

## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# If we were aiming and the mouse is released ...
	if _aiming and event.is_action_released("click"):
		_release_tomato()


## Releases the tomato aimed at the current cursor position
func _release_tomato() -> void:
	stop_aiming()
	
	# If the cursor is over the basket: put down the tomato
	if _cursor_over_area:
		return
		
	# Else... Raycast to know where the cursor is pointing to
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
	raycast.global_position = ray_origin
	raycast.look_at(ray_end)
	await get_tree().process_frame # black magic
	var target_obj: Object = raycast.get_collider()
	var target_pos: Vector3 = raycast.get_collision_point()
	
	# If the raycast hit nothing: nothing happens :(
	if target_obj == null:
		return
		
	# Else... we shoot ! :)
	# Instantiate the tomato
	var tomato_inst: Node3D = tomato_scene.instantiate()
	get_tree().root.add_child(tomato_inst)
	# Flight calculations
	# ... distance to target
	var dist_to_target: float = global_position.distance_to(target_pos)
	# ... how high will the tomato go
	var peak_height: float = dist_to_target * tomato_peak_height_coef 
	# ... the point that should be reached exactly mid-flight
	var mid_pos: Vector3 = global_position.lerp(target_pos, 0.5) + Vector3.UP * peak_height
	# ... flight duration, + some extra flight time but i dont remember why we need it
	var duration: float = (dist_to_target / tomato_speed) * tomato_safety_overshoot_coef
	# Tween animation
	var tween: Tween = create_tween()
	tween.bind_node(tomato_inst)
	tween.tween_method(
		func(t: float):
			var pos: Vector3 = _bezier(global_position, mid_pos, target_pos, t)
			var next_pos: Vector3 = _bezier(global_position, mid_pos, target_pos, t + 0.01)
			if pos.distance_to(next_pos) > 0.001:
				tomato_inst.look_at(next_pos)
			tomato_inst.global_position = pos
			,
		0.0, 
		tomato_safety_overshoot_coef, 
		duration)


## Math stuff
func _bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0: Vector3 = p0.lerp(p1, t)
	var q1: Vector3 = p1.lerp(p2, t)
	return q0.lerp(q1, t)
