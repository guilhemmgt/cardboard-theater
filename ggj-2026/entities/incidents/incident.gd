extends Node
class_name Incident

# DO NOT USE THIS CLASS DIRECTLY, USE ITS IMPLEMENTATIONS

signal resolved
signal failed
signal activated(blocking: bool)

@export var _timer: Timer
var _activated: bool

var blocking: bool = false

func _ready() -> void:
	_timer.timeout.connect(func(): deactivate(false))

func activate(time: float):
	if _activated:
		push_error("Already activated.")
	print("Event activated on node: " + str(self)+"with time" + str(time))
	_activated = true
	activated.emit(blocking)
	_timer.stop()
	_timer.wait_time = time
	_timer.start()

func deactivate(success: bool):
	if not _activated:
		push_error("Already deactivated.")
	# print("deactivated " + str(success))
	_activated = false
	_timer.stop()
	if success:
		resolved.emit()
	else:
		failed.emit()
