extends Node

@warning_ignore_start("unused_signal")

# UI signals
signal toggle_music ## Mute/unmute the music
signal play_sfx(stream: AudioStream) ## Play a SFX

# Theater signals
signal toggle_curtains ## Open/close the curtains
signal curtains_opening_started ## The curtains are closed but are about to open
signal curtains_opened ## The curtains are fully opened
signal curtains_closed ## The curtains are fully closed
signal init_curtains(open : bool) ## Set curtains position instantly (open/close)

signal ask_to_move(node: Node3D, duration: float, plan: int, pos: int)

@warning_ignore_restore("unused_signal")
