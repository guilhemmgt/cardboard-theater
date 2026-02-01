extends Node3D

@onready var intrusion_incident: IntrusionIncident
@onready var sfx_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var sfx_timer: Timer = $SfxTimer
@onready var control_timer: Timer = $ControlTimer
@export var orchestrator: Orchestrator
@export var control: Intru
@export var sfx_min_delay: float = 2.0
@export var sfx_max_delay: float = 4.0
@export var control_min_delay: float = 1.0
@export var control_max_delay: float = 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child and child is IntrusionIncident:
			intrusion_incident = child as IntrusionIncident
			break

	# events setup
	print("[intrusion] Ready on: ", name, " - IntrusionIncident: ", intrusion_incident)
	intrusion_incident.activated.connect(_on_incident_activated)
	intrusion_incident.failed.connect(_on_incident_failed)
	intrusion_incident.resolved.connect(_on_incident_resolved)
	
	#
	sfx_timer.timeout.connect(_on_sfx_timer_timeout)
	control_timer.timeout.connect(_on_control_timer_timeout)
	control.orchestrator = orchestrator
	control.init()
	
func _on_incident_activated(_blocking: bool) -> void:
	print("[intrusion] Activated on: ", name)
	# play sfx from time to time
	_on_sfx_timer_timeout()
	# move the intruder around
	_on_control_timer_timeout()

func _on_incident_failed() -> void:
	print("[intrusion] Failed on: ", name)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", self.position - Vector3(0, 10 ,0), 1.0)
	tween.play()
	tween.finished.connect(func(): queue_free())

func _on_incident_resolved() -> void:
	print("[intrusion] Resolved on: ", name)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", self.position - Vector3(0, 10 ,0), 1.0)
	tween.play()
	tween.finished.connect(func(): queue_free())

func start_random_timer(t: Timer, min_delay: float, max_delay:float) -> void:
	t.stop()
	t.wait_time = randf_range(min_delay, max_delay)
	t.start()

func _on_sfx_timer_timeout():
	if not intrusion_incident._activated:
		return
	sfx_player.play()
	start_random_timer(sfx_timer, sfx_min_delay, sfx_max_delay)

func _on_control_timer_timeout():
	if not intrusion_incident._activated:
		return
	control.move(randi_range(1, 4), 3)
	start_random_timer(control_timer, control_min_delay, control_max_delay)
