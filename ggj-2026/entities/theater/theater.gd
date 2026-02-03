extends Node3D

@export var curtains_anim_duration: float

@onready var _musicPlayer: AudioStreamPlayer = $MusicPlayer
@onready var _sfxPlayer: AudioStreamPlayer = $SfxPlayer

@onready var _curtain_left: Node3D = $Scene/Curtains/CurtainLeft
@onready var _curtain_right: Node3D = $Scene/Curtains/CurtainRight

var _music_volume: float = 0.0
func set_music(active: bool):
	if not active:
		_music_volume = _musicPlayer.volume_db
	_musicPlayer.volume_db = _music_volume if active else -80.0

func play_sfx(stream: AudioStream):
	_sfxPlayer.stream = stream
	_sfxPlayer.play()
