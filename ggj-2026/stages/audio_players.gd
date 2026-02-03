extends Node

@onready var _musicPlayer: AudioStreamPlayer = $MusicPlayer
@onready var _sfxPlayer: AudioStreamPlayer = $SfxPlayer

func _ready() -> void:
	SignalBus.toggle_music.connect(func(): set_music(not _music_mute))
	SignalBus.play_sfx.connect(play_sfx)

var _music_mute: bool = false ## Is the music currently mute ?
var _music_volume: float = 0.0 ## Save the normal music volume
func set_music(mute: bool):
	# defense
	if mute == _music_mute:
		push_warning("Tried to mute (or unmute) already muted (or unmuted) music.")
		return
	# mute / unmute
	if mute:
		_music_volume = _musicPlayer.volume_db
	_musicPlayer.volume_db = -80.0 if mute else _music_volume
	_music_mute = mute

func play_sfx(stream: AudioStream):
	_sfxPlayer.stream = stream
	_sfxPlayer.play()
