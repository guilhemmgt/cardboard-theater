extends Node3D

@export var repair : RepairIncident
@export var dialog : DialogIncident
@export var activation : ActivationIncident
@export var whisper : RichTextLabel

func _ready() -> void:
	dialog.write_letter.connect(update_ui_whisper)
	repair.activate(10)
	dialog.activate(10)
	activation.activate(10)
	
func update_ui_whisper(text:String):
	whisper.text = text
