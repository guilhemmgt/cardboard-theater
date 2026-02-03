extends Node

# UI signals
signal toggle_music ## Mute/unmute the music
signal toggle_sfx ## Mute/unmute the SFXs

# Theater signals
signal toggle_curtains ## Open/close the curtains
signal curtains_opening_started ## The curtains are closed but are about to open
signal curtains_opened ## The curtains are fully opened
signal curtains_closed ## The curtains are fully closed
