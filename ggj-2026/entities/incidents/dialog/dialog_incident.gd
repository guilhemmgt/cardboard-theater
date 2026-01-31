extends Incident
class_name DialogIncident

signal write_letter(text:String)

var text_to_write: String
var _lower_text_to_write: String
@export var color_not_written: Color
@export var color_written: Color
@export var color_error: Color
var letters_written: int

func _ready() -> void:
	letters_written = 0

func set_text_to_write(dialog: String):
	text_to_write = dialog

func activate(time: float):
	_lower_text_to_write = text_to_write.to_lower()
	super.activate(time)
	
	update_dialog_ui(true)

func _event_to_string(event: InputEvent) -> String:
	var letter : String = event.as_text().to_lower()
	print(letter)
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
	var text:String = "[color="+str(color_written.to_html())+ "]"+text_to_write.left(letters_written) + "[/color]"
	if !success:
		var false_letter : String = text_to_write[letters_written]
		if false_letter == " ":
			false_letter = "▍"
		text +=  "[color="+str(color_error.to_html())+"]"+false_letter+"[/color]"
	text +=  "[color="+str(color_not_written.to_html())+"]"+text_to_write.right(len(text_to_write) - letters_written - (1-int(success)))+"[/color]"
	write_letter.emit(text)
	
