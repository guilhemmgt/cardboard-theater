extends Area3D

const SLAPSH : AudioStream = preload("uid://dtnrhf2cox0sr")

@export var sprotch_texture: Texture
@export var sprotch_sound: AudioStreamPlayer3D
var body_touch : bool

func _ready() -> void:
	body_touch = false
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node3D):
	if (body_touch):
		return
	
	print("tomata has hit" + body.name)
	body_touch = true
	self.visible = false
	
	if body is SprouchBody:
		var sprouch_body : SprouchBody = body
		sprouch_body.sprouch.emit()
	if body.get_parent() is TomatoBasket:
		return
		
	if body.get_parent().get_parent():
		for ch in body.get_parent().get_parent().get_children():
			print(ch.name)
			if ch is IntrusionIncident:
				var intrusion: IntrusionIncident = ch
				intrusion.deactivate(true)
	# sprotch !!!
	var decal: Decal = Decal.new()
	decal.texture_albedo = sprotch_texture
	decal.size = Vector3(0.2, 1, 0.2)
	body.add_child(decal)
	decal.global_position = global_position
	var normal: Vector3 = global_transform.basis.z # cheap way to compute normal, since tomato_basket.gd tweens the tomato to face its trajectory
	var up = Vector3.UP if abs(normal.y) < 0.9 else Vector3.RIGHT
	decal.look_at(global_position + normal, up)
	decal.rotate_object_local(Vector3.RIGHT, PI/2)
	sprotch_sound.play()
	print("sproch_sound")
	#var tween = create_tween()
	#tween.tween_property(decal, "modulate:a", 0, 5).set_delay(10)
	# good bye tomato
	await sprotch_sound.finished
	queue_free()
