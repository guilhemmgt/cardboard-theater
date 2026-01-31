extends Node3D

@export var repair : RepairIncident
@export var dialog : DialogIncident
@export var activation : ActivationIncident
@export var random_incident : RandomIncident
@export var all_incident : AllIncident
@export var whisper : RichTextLabel

func _ready() -> void:
	dialog.write_letter.connect(update_ui_whisper)
	# repair.activate(10)
	dialog.set_text_to_write("Polish")
	# dialog.activate(10)
	# activation.activate(10)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		all_incident.activate(5)
		# random_incident.activate(5)

func update_ui_whisper(text:String):
	whisper.text = text
