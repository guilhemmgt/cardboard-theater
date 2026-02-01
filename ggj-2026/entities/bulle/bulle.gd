extends Node3D
class_name Bulle

signal dialog_finished
@onready var label_3d: Label3D = $Label3D
@onready var bulle_main: MeshInstance3D = $BulleMain
@export var bubble_marker: Node3D
# Padding autour du texte (en unités 3D)
@export var padding: Vector2 = Vector2(0.2, 0.1)
@onready var bubble_handle: Node3D = $BulleMain/Node3D
var debug_draw: Node2D = null


# Appeler cette fonction pour mettre à jour le texte et la taille de la bulle
func set_text(new_text: String) -> void:
	label_3d.text = new_text

# Affiche le texte mot par mot avec un timing donné
func start_dialog(text: String, duration: float) -> void:
	visible = true
	print("\n\nSTARTING DIALOG \n\n")
	var marker_global_pos = bubble_marker.global_position
	var handle_global_pos = bubble_handle.global_position
	if bubble_marker and marker_global_pos.x - handle_global_pos.x > 0:
		print("LEFT SIDE")
		global_position.z = 0.8
		global_position.x = bubble_marker.global_position.x - bulle_main.scale.x / 2 -0.5
		global_position.y = bubble_marker.global_position.y + bulle_main.scale.y / 2 +1.0
	else:
		print("RIGHT SIDE")
		global_position.z = 0.8
		global_position.x = bubble_marker.global_position.x + bulle_main.scale.x / 2 + 0.5
		global_position.y = bubble_marker.global_position.y + bulle_main.scale.y / 2 +1.0
		#rotate handle 180 degrees if dir is negative
	if marker_global_pos.x - handle_global_pos.x < 0:
		bubble_handle.rotation.y = PI


	if text.is_empty():
		return
	# Réinitialise le texte
	label_3d.text = ""
	
	# Sépare le texte en mots (en gardant les retours à la ligne)
	var words = text.split(" ")
	print(visible)	
	# Calcule le délai entre chaque mot
	var delay_per_word = duration / float(words.size())
	
	# Affiche chaque mot un par un (remplace le précédent)
	for i in range(words.size()):
		label_3d.text = words[i]
		await get_tree().create_timer(delay_per_word).timeout
	print("\n\n ENDING DIAL \n\n")
	visible = false
	global_position.z = -10.0
