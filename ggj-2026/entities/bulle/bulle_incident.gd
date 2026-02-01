extends Node3D
class_name Bulle
@onready var dialog_incident: DialogIncident = $DialogIncident
@onready var goodletter: Label3D = $goodletter
@onready var wrongletter: Label3D = $wrongletter
@onready var waitedletter: Label3D = $waitedletter

signal dialog_finished
@onready var bulle_main: MeshInstance3D = $BulleMain
@export var bubble_marker: Marker3D
# Padding autour du texte (en unités 3D)
@export var padding: Vector2 = Vector2(0.2, 0.1)
@onready var bubble_handle: Node3D = $BulleMain/Node3D
var debug_draw: Node2D = null

func _ready() -> void:
	dialog_incident.set_text_to_write("Welcome")
	dialog_incident.activate(100)

func update_bubble_handle_position() -> void:
	if not bubble_marker:
		return
	
	# Fait regarder le handle vers le marker (rotation autour de Z uniquement)
	var marker_global_pos = bubble_marker.global_position
	var handle_global_pos = bubble_handle.global_position

	
	# Calcule la direction dans le plan XY
	var direction = Vector2(
		float(marker_global_pos.x - handle_global_pos.x),
		float(marker_global_pos.y - handle_global_pos.y)
	)


	# Calcule l'angle et applique la rotation autour de Z
	var angle = direction.angle()

	bubble_handle.rotation.z = angle


func update_bulle_size() -> void:
	# Récupère la font et la taille de font du Label3D
	var font: Font = waitedletter.font if waitedletter.font else ThemeDB.fallback_font
	var font_size: int = waitedletter.font_size
	
	# Calcule la taille du texte en pixels
	var text_size: Vector2 = font.get_multiline_string_size(
		waitedletter.text,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		font_size
	)
	
	# Convertit la taille en unités 3D (pixel_size du Label3D)
	var pixel_size: float = waitedletter.pixel_size
	var size_3d: Vector2 = text_size * pixel_size
	
	# Applique un scale uniforme au mesh avec padding
	var scale_x = size_3d.x + padding.x * 2
	var scale_y = size_3d.y + padding.y * 2
	var uniform_scale = max(scale_x, scale_y)
	
	bulle_main.scale.x = uniform_scale
	bulle_main.scale.y = uniform_scale


# Appeler cette fonction pour mettre à jour le texte et la taille de la bulle
func set_text(new_text: String) -> void:
	if waitedletter != null:
		waitedletter.text = new_text
		update_bulle_size()
	else:
		print("Warning: waitedletter node is null")


# Affiche le texte lettre par lettre avec un timing donné
func start_dialog(text: String, duration: float) -> void:
	if text.is_empty():
		return
	update_bubble_handle_position()
	# Réinitialise le texte
	waitedletter.text = ""
	update_bulle_size()
	
	# Calcule le délai entre chaque lettre
	var delay_per_letter = duration / float(text.length())
	
	# Affiche chaque lettre une par une avec await
	for i in range(text.length()):
		waitedletter.text += text[i]
		update_bulle_size()
		await get_tree().create_timer(delay_per_letter).timeout

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
			return "▍"  # Visual indicator for space
		return next_letter
	return ""  # No more letters expected
