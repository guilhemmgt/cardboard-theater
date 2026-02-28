extends Decal
class_name TomatoDecal

func _ready() -> void:
	SignalBus.act_start.connect(disappear) 

func disappear(): 
	print("decal disappearing")
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 3)
	tween.play()
	await tween.finished
	print("Tween finished")
	self.queue_free()
