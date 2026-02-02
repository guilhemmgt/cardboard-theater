@tool
extends Incident
class_name ActivationIncident

@onready var collisionShape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var area: Area3D = $Area3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var anim_name: String # sus
@onready var light: SpotLight3D = $SpotLight3D

@export var anim_player_sucess : AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	collisionShape.disabled = true
	area.input_event.connect(on_click)
	blocking = true
	light.visible = false

func activate(time: float):
	super.activate(time)
	collisionShape.disabled = false
	light.visible = true
	print("lightblink")
	animation_player.play("light_blink")
	
func deactivate(success: bool):
	collisionShape.disabled = true
	super.deactivate(success)
	if success :
		print("success")
		light.visible = false
		anim_player_sucess.stop()
		if anim_name == null:
			push_error("no anim")
			return
		if anim_name == "":
			push_error("no anim")
			return
		anim_player_sucess.play(anim_name)
		light.visible = false
	else :
		print("failed")
		animation_player.stop()
		light.visible = false
func on_click(_camera: Node,
			  event: InputEvent,
			  _event_position: Vector3,
			  _normal: Vector3,
			  _shape_idx: int):
	if (event.is_action_pressed('click')):
		deactivate(true)
