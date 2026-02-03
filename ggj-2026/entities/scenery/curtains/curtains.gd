@tool
extends Node3D

@onready var _left: Node3D = $CurtainLeft
@onready var _right: Node3D = $CurtainRight

@export var animation_speed: float

var _open: bool = false

var opened_x: float = 6.0 # hardcodé comme un bourrin
var closed_x: float = 1.925  # hardcodé comme un bourrin

func _ready() -> void:
	SignalBus.toggle_curtains.connect(func(): set_curtains(not _open))

func set_curtains(open: bool):
	# defense
	if open == _open:
		push_warning("Tried to open (or close) already opened (or closed) curtains.")
		return
	# before the tween...
	if open:
		SignalBus.curtains_opening_started.emit()
	# tween
	var to_x: float = opened_x if open else closed_x
	var duration: float = abs(to_x - _left.position.x) / animation_speed
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(_left, "position:x", to_x, duration)
	tween.tween_property(_right, "position:x", -to_x, duration)
	# after the tween...
	tween.finished.connect(func(): _open = not _open)
	if open:
		tween.finished.connect(func(): SignalBus.curtains_opened.emit())
	else:
		tween.finished.connect(func(): SignalBus.curtains_closed.emit())

func debug_set_curtains(open: bool):
	# defense
	if open == _open:
		push_warning("Tried to open (or close) already opened (or closed) curtains.")
		return
	# teleport
	var to_x: float = opened_x if open else closed_x
	_left.position.x = to_x
	_right.position.x = -to_x
	# after
	_open = not _open
