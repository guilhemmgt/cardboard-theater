extends Incident
class_name IntrusionIncident

@onready var sfx_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var sfx_timer: Timer = $SfxTimer
@onready var control_timer: Timer = $ControlTimer
@export var sfx_min_delay: float = 2.0
@export var sfx_max_delay: float = 4.0
@export var control_min_delay: float = 1.0
@export var control_max_delay: float = 4.0

@export var is_left_oriented: bool = true

var current_node: int = 0
var is_current_node_initialized: bool = false

func _ready() -> void:
	super._ready()
	blocking = false
	sfx_timer.timeout.connect(_on_sfx_timer_timeout)
	control_timer.timeout.connect(_on_control_timer_timeout)

func activate(time: float):
	super.activate(time)
	print("Activated on: ", name)
	_on_sfx_timer_timeout()
	_on_control_timer_timeout()

func deactivate(success: bool) -> void:
	super.deactivate(success)
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
	print("asking to move")
	#pick random different node
	var new_node: int 
	if not is_current_node_initialized:
		new_node = randi_range(0, 3)
		is_current_node_initialized = true
	else:
		new_node = randi_range(0, 3)
		while current_node == new_node:
			new_node = randi_range(0, 3)
		current_node = new_node
	SignalBus.ask_to_move.emit(self, randf_range(control_min_delay, control_max_delay), 0, new_node)
	start_random_timer(control_timer, control_min_delay, control_max_delay)
