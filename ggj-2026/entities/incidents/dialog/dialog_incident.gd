extends Incident
class_name DialogIncident

signal write_letter(json_data:Dictionary)

var text_to_write: String
var _lower_text_to_write: String
@export var color_not_written: Color
@export var color_written: Color
@export var color_error: Color
var letters_written: int

func _ready():
	blocking=true

func set_text_to_write(dialog: String):
	text_to_write = dialog

func activate(time: float):
	letters_written = 0
	_lower_text_to_write = text_to_write.to_lower()
	super.activate(time)
	print("dec : ",_activated)
	update_dialog_ui(true)

func _event_to_string(event: InputEvent) -> String:
	var letter : String = event.as_text().to_lower()
	if letter == "space":
		letter = " "
	if letter == "exclam":
		letter = "!"
	if letter == "comma":
		letter = ","
	if letter == "apostrophe":
		letter = "'"
	return letter

func _unhandled_input(event: InputEvent) -> void:
	if _activated:
		if event.is_released() && !(event is InputEventMouse):
			print("ev")
			var letter_released: String = _event_to_string(event)
			#if right letter
			if letter_released == _lower_text_to_write[letters_written]:
				letters_written+=1
				update_dialog_ui(true)
				# if text finished
				if letters_written == len(text_to_write):
					deactivate(true)
			else :
				update_dialog_ui(false)


func update_dialog_ui(success:bool):
	var written_letter = text_to_write.left(letters_written)
	var failed_letter = ""
	var waited_letter = ""
	
	if !success:
		failed_letter = text_to_write[letters_written]
		if failed_letter == " ":
			failed_letter = "▍"
		waited_letter = text_to_write.right(len(text_to_write) - letters_written - 1)
	else:
		waited_letter = text_to_write.right(len(text_to_write) - letters_written)
	
	var json_data = {
		"written_letter": written_letter,
		"failed_letter": failed_letter,
		"waited_letter": waited_letter
	}
	
	write_letter.emit(json_data)
	
