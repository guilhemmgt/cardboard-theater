extends Node3D
class_name BulleIncident
@onready var dialog_incident: DialogIncident
@onready var goodletter: Label3D = $goodletter
@onready var wrongletter: Label3D = $wrongletter
@onready var waitedletter: Label3D = $waitedletter

signal dialog_finished
@onready var bulle_main: MeshInstance3D = $BulleMain
@export var bubble_marker: Node3D
# Padding autour du texte (en unités 3D)
@export var padding: Vector2 = Vector2(0.2, 0.1)
@onready var bubble_handle: Node3D = $BulleMain/Node3D
var debug_draw: Node2D = null

func _ready() -> void:
	for child in get_children():
		if child is DialogIncident:
			dialog_incident = child as DialogIncident
			break
func update_bubble_handle_position() -> void:
	if not bubble_marker:
		return
	
	# Fait regarder le handle vers le marker (rotation autour de Z uniquement)
	var marker_global_pos = bubble_marker.global_position
	var handle_global_pos = bubble_handle.global_position

	
	var dir = marker_global_pos.x - handle_global_pos.x

	#rotate handle 180 degrees if dir is negative
	if dir < 0:
		bubble_handle.rotation.y = PI



func update_bulle_size() -> void:
	var marker_global_pos = bubble_marker.global_position
	var handle_global_pos = bubble_handle.global_position
	print("avantif",bubble_marker and marker_global_pos.x - handle_global_pos.x > 0)
	if bubble_marker and marker_global_pos.x - handle_global_pos.x > 0:
		print("LEFT SIDE")
		global_position.z = 0.8
		global_position.x = bubble_marker.global_position.x - bulle_main.scale.x / 2 -0.5
		global_position.y = bubble_marker.global_position.y + bulle_main.scale.y / 2 +1.0
	else:
		print("RIGHT SIDE")
		global_position.z = 0.8
		global_position.x = bubble_marker.global_position.x + bulle_main.scale.x / 2 + 3.0
		global_position.y = bubble_marker.global_position.y + bulle_main.scale.y / 2 +1.0
	# Récupère la font et la taille

# Appeler cette fonction pour mettre à jour le texte et la taille de la bulle
func set_text(new_text: String) -> void:
	if waitedletter != null:
		waitedletter.text = new_text
		update_bulle_size()
	else:
		print("Warning: waitedletter node is null")


func auto_wrap(text: String, max_letters_per_line: int) -> String:
	var words = text.split(" ")
	var wrapped_text = ""
	var current_line = ""
	
	for word in words:
		if current_line.length() + word.length() + 1 <= max_letters_per_line:
			if current_line != "":
				current_line += " "
			current_line += word
		else:
			if wrapped_text != "":
				wrapped_text += "\n"
			wrapped_text += current_line
			current_line = word
	
	if current_line != "":
		if wrapped_text != "":
			wrapped_text += "\n"
		wrapped_text += current_line
	
	return wrapped_text


func _on_dialog_incident_write_letter(json: Dictionary) -> void:
	print("Received dialog data: ", json)
	visible = true
	update_labels_from_dictionary(json)

# Handle dictionary data to update all labels appropriately
func update_labels_from_dictionary(json_data: Dictionary) -> void:
	var written_letter = json_data.get("written_letter", "")
	var failed_letter = json_data.get("failed_letter", "")
	var waited_letter = json_data.get("waited_letter", "")
	
	# Show full typed text in main label (including spaces for already typed letters)
	goodletter.text = create_written_with_spaces(written_letter, failed_letter, waited_letter)
	wrongletter.text = create_failed_with_spaces(written_letter, failed_letter, waited_letter)
	waitedletter.text = create_waited_with_spaces(written_letter, failed_letter, waited_letter)
	set_text(waitedletter.text)
	#compare size
	print("Sizes - Good: ", goodletter.text.length(), " Wrong: ", wrongletter.text.length(), " Waited: ", waitedletter.text.length())


# Show only already typed letters, replace others with spaces
func create_written_with_spaces(written: String, failed: String, waited: String) -> String:
	return written + " ".repeat(failed.length() + waited.length())

# Show only wrong letters, replace others with spaces  
func create_failed_with_spaces(written: String, failed: String, waited: String) -> String:
	return " ".repeat(written.length()) + failed + " ".repeat(waited.length())

func create_waited_with_spaces(written: String, failed: String, waited: String) -> String:
	return " ".repeat(written.length() + failed.length()) + waited

# Get the next expected letter
func get_next_expected_letter(written: String, waited: String) -> String:
	if waited.length() > 0:
		var next_letter = waited[0]
		if next_letter == " ":
			return "▍" # Visual indicator for space
		return next_letter
	return "" # No more letters expected


func _on_dialog_incident_resolved() -> void:
	await get_tree().create_timer(0.5).timeout
	visible = false
	global_position.z = -10.0
