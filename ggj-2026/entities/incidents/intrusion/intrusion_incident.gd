extends Incident
class_name IntrusionIncident

@onready var sfx_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var sfx_timer: Timer = $SfxTimer
@onready var control_timer: Timer = $ControlTimer
@export var sfx_min_delay: float = 2.0
@export var sfx_max_delay: float = 4.0
@export var control_min_delay: float = 1.0
@export var control_max_delay: float = 4.0


func _ready() -> void:
	blocking = false
	sfx_timer.timeout.connect(_on_sfx_timer_timeout)
	control_timer.timeout.connect(_on_control_timer_timeout)

func _activate(_blocking: bool) -> void:
	print("Activated on: ", name)
	_on_sfx_timer_timeout()
	_on_control_timer_timeout()

func _deactivate(success: bool) -> void:
	print("Deactivated on: ", name)
	if success:
		_on_incident_resolved()
	else:
		_on_incident_failed()

func _on_incident_failed() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", self.position - Vector3(0, 10, 0), 1.0)
	tween.play()
	tween.finished.connect(func(): queue_free())

func _on_incident_resolved() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", self.position - Vector3(0, 10, 0), 1.0)
	tween.play()
	tween.finished.connect(func(): queue_free())

func start_random_timer(t: Timer, min_delay: float, max_delay: float) -> void:
	t.stop()
	t.wait_time = randf_range(min_delay, max_delay)
	t.start()

func _on_sfx_timer_timeout():
	if not _activated:
		return
	sfx_player.play()
	start_random_timer(sfx_timer, sfx_min_delay, sfx_max_delay)

func _on_control_timer_timeout():
	if not _activated:
		return
	SignalBus.ask_to_move.emit(self, randf_range(control_min_delay, control_max_delay), 1, randi_range(1, 4))
	start_random_timer(control_timer, control_min_delay, control_max_delay)
