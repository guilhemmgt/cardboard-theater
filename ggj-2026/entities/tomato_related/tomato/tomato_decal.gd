extends Decal
class_name TomatoDecal

var _tracked_body: Node3D = null
var _offset: Vector3 = Vector3.ZERO # offset in the body's local space


func start_tracking(body: Node3D, hit_global_pos: Vector3) -> void:
	_tracked_body = body
	_offset = body.global_transform.affine_inverse() * hit_global_pos


func _ready() -> void:
	SignalBus.start_act.connect(disappear)


func _process(_delta: float) -> void:
	if not is_instance_valid(_tracked_body):
		return
	global_position = _tracked_body.global_transform * _offset


func disappear():
	var tween: Tween = create_tween()
	tween.tween_property(self , "modulate:a", 0, 3)
	tween.play()
	await tween.finished
	self.queue_free()


## Generates a random tomato splat texture.
## Returns an ImageTexture
static func generate_splat_texture(tex_size: int = 128) -> ImageTexture:
	var img := Image.create(tex_size, tex_size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0)) # transparent

	var center := Vector2(tex_size / 2.0, tex_size / 2.0)
	var base_radius := tex_size * 0.25

	var tomato_color := Color(0.93, 0.27, 0.22)

	var blob_count: int = randi_range(8, 14)
	for i in range(blob_count):
		var angle := randf() * TAU
		var offset_dist := randf() * base_radius * 0.5
		#plus vers le bas car la tomate coule
		var blob_center := center + Vector2(0, randf_range(-3.0, 0.0)) + Vector2(cos(angle), sin(angle)) * offset_dist
		var blob_radius := base_radius * randf_range(0.5, 1.0)
		_draw_filled_circle(img, blob_center, blob_radius, tomato_color)

	var lobe_count: int = randi_range(4, 8)
	for i in range(lobe_count):
		var angle := randf() * TAU
		var dist := base_radius * randf_range(0.6, 1.2)
		var lobe_center := center + Vector2(cos(angle), sin(angle)) * dist
		var lobe_radius := base_radius * randf_range(0.2, 0.45)
		_draw_filled_circle(img, lobe_center, lobe_radius, tomato_color)

	#droplets
	var droplet_count: int = randi_range(4, 8)
	for i in range(droplet_count):
		var angle := randf() * TAU
		var dist := base_radius * randf_range(1.4, 2.0)
		var drop_center := center + Vector2(cos(angle), sin(angle)) * dist
		var drop_radius := base_radius * randf_range(0.08, 0.18)
		_draw_filled_circle(img, drop_center, drop_radius, tomato_color)

	var tex := ImageTexture.create_from_image(img)
	return tex

#Probably a better way to do this but it works and its fast enough

## Draw a filled circle on an Image pixel by pixel.
static func _draw_filled_circle(img: Image, center: Vector2, radius: float, color: Color) -> void:
	var r2 := radius * radius
	var min_x := maxi(0, int(center.x - radius))
	var max_x := mini(img.get_width() - 1, int(center.x + radius))
	var min_y := maxi(0, int(center.y - radius))
	var max_y := mini(img.get_height() - 1, int(center.y + radius))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var dx := x - center.x
			var dy := y - center.y
			var dist2 := dx * dx + dy * dy
			if dist2 <= r2:
				# Smooth edge: anti-alias the last 1.5 pixels. Formula found online.
				var dist := sqrt(dist2)
				var edge_alpha := clampf((radius - dist) / 1.5, 0.0, 1.0)
				var existing := img.get_pixel(x, y)
				var c := color
				c.a = edge_alpha

				# Merging color alpha
				var out_a := c.a + existing.a * (1.0 - c.a)
				if out_a > 0.001:
					var out_color := Color(
						(c.r * c.a + existing.r * existing.a * (1.0 - c.a)) / out_a,
						(c.g * c.a + existing.g * existing.a * (1.0 - c.a)) / out_a,
						(c.b * c.a + existing.b * existing.a * (1.0 - c.a)) / out_a,
						out_a
					)
					img.set_pixel(x, y, out_color)
