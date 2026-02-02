extends Node3D

@export var curtains_anim_duration: float

@onready var _musicPlayer: AudioStreamPlayer = $MusicPlayer
@onready var _sfxPlayer: AudioStreamPlayer = $SfxPlayer

@onready var _curtain_left: Node3D = $Scene/Scene/Curtains/curtain_left
@onready var _curtain_right: Node3D = $Scene/Scene/Curtains/curtain_right

var _curtains_open: bool = true
func set_curtains(open: bool):
	if open == _curtains_open:
		push_warning("Tried to open (or close) already opened (or closed) curtains.")
		return
	var to_x: float = 6 if open else 1.925
	create_tween().tween_property(_curtain_left, "position:x", to_x, curtains_anim_duration)
	create_tween().tween_property(_curtain_right, "position:x", -to_x, curtains_anim_duration)

var _music_volume: float = _musicPlayer.volume_db
func set_music(active: bool):
	_musicPlayer.volume_db = _music_volume if active else -80.0

func play_sfx(stream: AudioStream):
	_sfxPlayer.stream = stream
	_sfxPlayer.play()
