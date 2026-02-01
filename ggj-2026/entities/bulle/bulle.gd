extends Node3D
class_name BulleIncident

signal dialog_finished
@onready var label_3d: Label3D = $Label3D
@onready var bulle_main: MeshInstance3D = $BulleMain
@export var bubble_marker: Marker3D
# Padding autour du texte (en unités 3D)
@export var padding: Vector2 = Vector2(0.2, 0.1)
@onready var bubble_handle: Node3D = $BulleMain/Node3D
var debug_draw: Node2D = null

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
	var font: Font = label_3d.font if label_3d.font else ThemeDB.fallback_font
	var font_size: int = label_3d.font_size
	
	# Calcule la taille du texte en pixels
	var text_size: Vector2 = font.get_multiline_string_size(
		label_3d.text,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		font_size
	)
	
	# Convertit la taille en unités 3D (pixel_size du Label3D)
	var pixel_size: float = label_3d.pixel_size
	var size_3d: Vector2 = text_size * pixel_size
	
	# Applique un scale uniforme au mesh avec padding
	var scale_x = size_3d.x + padding.x * 2
	var scale_y = size_3d.y + padding.y * 2
	var uniform_scale = max(scale_x, scale_y)
	
	bulle_main.scale.x = uniform_scale
	bulle_main.scale.y = uniform_scale


# Appeler cette fonction pour mettre à jour le texte et la taille de la bulle
func set_text(new_text: String) -> void:
	label_3d.text = new_text
	update_bulle_size()


# Affiche le texte lettre par lettre avec un timing donné
func start_dialog(text: String, duration: float) -> void:
	if text.is_empty():
		return
	update_bubble_handle_position()
	# Réinitialise le texte
	label_3d.text = ""
	update_bulle_size()
	
	# Calcule le délai entre chaque lettre
	var delay_per_letter = duration / float(text.length())
	
	# Affiche chaque lettre une par une avec await
	for i in range(text.length()):
		label_3d.text += text[i]
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
