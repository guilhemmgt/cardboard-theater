extends Area3D

@onready var sprotch_player: AudioStreamPlayer3D = $Splash
@export var sprotch_texture: Texture
var _sprotched_already: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D):
	if (_sprotched_already):
		return
	_sprotched_already = true
	
	# Signal
	SignalBus.tomato_hit.emit(body, global_position)

	# Ignore the basket
	if body.get_parent() is TomatoBasket:
		return
		
	# HACK Very shitty way to kill an intruder
	if body.get_parent().get_parent():
		for ch in body.get_parent().get_parent().get_children():
			if ch is IntrusionIncident:
				var intrusion: IntrusionIncident = ch
				intrusion.deactivate(true)
	
	# Instantiate SPROTCH sprite
	var decal: TomatoDecal = TomatoDecal.new()
	decal.texture_albedo = sprotch_texture	
	decal.size = Vector3(0.2, 1, 0.2) / body.get_parent_node_3d().scale
	body.add_child(decal)
	decal.global_position = global_position
	var normal: Vector3 = global_transform.basis.z # cheap way to compute normal, since tomato_basket.gd tweens the tomato to face its trajectory
	var up : Vector3 = Vector3.UP if abs(normal.y) < 0.9 else Vector3.RIGHT
	decal.look_at(global_position + normal, up)
	decal.rotate_object_local(Vector3.RIGHT, PI/2)
	
	# SFX
	sprotch_player.play()
	
	# Disappear, then destroy when SFX is done
	self.visible = false
	await sprotch_player.finished
	queue_free() # good bye tomato
