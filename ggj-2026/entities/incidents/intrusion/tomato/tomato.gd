extends Area3D

func _ready() -> void:
	area_entered.connect(on_area_entered)
	
func on_area_entered(area: Area3D):
	if area.get_parent() is TomatoBasket:
		return
	if area.get_parent() is IntrusionIncident:
		var intrusion: IntrusionIncident = area.get_parent()
		intrusion.deactivate(true)
	# might cause troubles :
	queue_free()
