extends Node3D
class_name TomatoBasket
signal drag(is_dragging: bool)

@export var camera: Camera3D
@export var tomato_scene: PackedScene
@export var area: Area3D
@export var raycast: RayCast3D

@export var tomato_speed: float
@export var tomato_peak_height_coef: float
@export var tomato_safety_overshoot_coef: float

var aiming : bool

func _ready():
	area.input_event.connect(func(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int):
		if event.is_action_pressed('click'):
			aim()
			drag.emit(true)
	)

func dearm():
	aiming = false
	
func aim():
	aiming = true
		
func shoot(target_pos: Vector3):
	#print("[tomato] fire !")
	dearm()
	var dist_to_target: float = global_position.distance_to(target_pos)
	var tomato_inst: Node3D = tomato_scene.instantiate()
	get_tree().root.add_child(tomato_inst)
	var peak_height: float = dist_to_target * tomato_peak_height_coef
	var mid_pos: Vector3 = global_position.lerp(target_pos, 0.5) + Vector3.UP * peak_height
	var duration: float = (dist_to_target / tomato_speed) * tomato_safety_overshoot_coef
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
	
func _bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0: Vector3 = p0.lerp(p1, t)
	var q1: Vector3 = p1.lerp(p2, t)
	return q0.lerp(q1, t)
		

func _input(event: InputEvent) -> void:
	if aiming and event.is_action_released("click"):
		# raycast
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_end: Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
		raycast.global_position = ray_origin
		raycast.look_at(ray_end)
		#print("ray end", ray_end)
		#print("ray global pos", raycast.global_position)
		#print("ray global rot", raycast.global_rotation_degrees)
		await get_tree().process_frame
		var r_obj = raycast.get_collider()
		var r_pos: Vector3 = raycast.get_collision_point()
		#print(r_obj, r_pos)
		drag.emit(false)
		if r_obj == area:
			dearm()
			return
		if r_obj == null:
			return
		shoot(r_pos)
