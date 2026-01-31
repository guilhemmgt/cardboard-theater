extends Node
class_name Incident

# DO NOT USE THIS CLASS DIRECTLY, USE ITS IMPLEMENTATIONS

signal resolved
signal failed
signal activated

@export var _timer: Timer
var _activated: bool

func _ready() -> void:
	_timer.timeout.connect(func(): deactivate(false))

func activate(time: float):
	if _activated:
		push_error("Already activated.")
	# print("activated")
	_activated = true
	activated.emit()
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
