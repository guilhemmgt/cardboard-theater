@tool
extends Node

# Références
@export_file("*.txt") var source_file_path: String
@export var target_animation_player: AnimationPlayer

# --- TON BOUTON ---
# Cette ligne ne marche QUE si tout le reste du script est sans erreur.
@export_tool_button("Générer Animation") var generate_button = _on_generate_pressed

const COMMAND_MAPPING = {
	"WaitForClick": "activate",
	"Move": "move",
	"Repair": "activate"
}

# Mapping for INCIDENT commands
const INCIDENT_COMMAND_MAPPING = {
	"SetDialogIncident": "set_text_to_write",
	"ActDialogIncident": "activate"
}


# La fonction appelée par le bouton
func _on_generate_pressed() -> void:
	if not source_file_path or not FileAccess.file_exists(source_file_path):
		printerr("ERREUR: Fichier introuvable.")
		return
	
	if not target_animation_player:
		printerr("ERREUR: AnimationPlayer manquant.")
		return

	print("Génération en cours...")
	parse_and_create_animation()

func parse_and_create_animation() -> void:
	var file = FileAccess.open(source_file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	# CORRECTION 1: On dit explicitement que c'est un tableau de Strings
	var lines: PackedStringArray = content.split("\n")
	
	var anim = Animation.new()
	anim.resource_name = "scene_generated"
	anim.length = 60.0
	anim.loop_mode = Animation.LOOP_NONE
	
	var tracks_cache = {}
	var current_section = ""
	
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("-------"):
			continue
			
		if line == "INIT":
			current_section = "INIT"
			continue
		elif line == "SCENE":
			current_section = "SCENE"
			continue
		
		# CORRECTION 2: Typage strict ici aussi
		var parts: PackedStringArray = line.split(" : ")
		
		if current_section == "SCENE":
			if parts.size() < 4:
				continue
				
			# CORRECTION 3: Conversion explicite String -> Float
			var time_str: String = parts[0]
			var time: float = time_str.to_float()
			
			var command_type: String = parts[1]
			var command_raw: String = parts[2]
			var target_name: String = parts[3]
			
			var args_raw: Array = []
			if parts.size() > 4:
				for i in range(4, parts.size()):
					args_raw.append(parts[i])
			
			# Handle INCIDENT type commands that go to DialogIncident
			if command_type == "INCIDENT" and command_raw in INCIDENT_COMMAND_MAPPING:
				var cache_key = "INCIDENT_" + target_name
				
				var incident_track_idx: int = -1
				if cache_key in tracks_cache:
					incident_track_idx = tracks_cache[cache_key]
				else:
					var node_path = _find_path_for_node(target_name)
					if node_path.is_empty():
						continue
					incident_track_idx = anim.add_track(Animation.TYPE_METHOD)
					anim.track_set_path(incident_track_idx, node_path)
					tracks_cache[cache_key] = incident_track_idx
				
				# Get method name from INCIDENT_COMMAND_MAPPING
				var method_name = INCIDENT_COMMAND_MAPPING.get(command_raw, command_raw.to_lower())
				var parsed_args = _parse_arguments(args_raw)
				
				var key_dict = {
					"method": method_name,
					"args": parsed_args
				}
				
				anim.track_insert_key(incident_track_idx, time, key_dict)
				continue
			
			# Gestion Piste (normal commands)
			var track_idx = -1
			if target_name in tracks_cache:
				track_idx = tracks_cache[target_name]
			else:
				var node_path = _find_path_for_node(target_name)
				# Skip if node not found (empty path)
				if node_path.is_empty():
					continue
				track_idx = anim.add_track(Animation.TYPE_METHOD)
				anim.track_set_path(track_idx, node_path)
				tracks_cache[target_name] = track_idx
			
			# Gestion Clé
			var method_name = COMMAND_MAPPING.get(command_raw, command_raw.to_lower())
			var parsed_args = _parse_arguments(args_raw)
			
			var key_dict = {
				"method": method_name,
				"args": parsed_args
			}
			
			anim.track_insert_key(track_idx, time, key_dict)
	
	# Mise à jour AnimationPlayer
	var lib = target_animation_player.get_animation_library("")
	if lib == null:
		lib = AnimationLibrary.new()
		target_animation_player.add_animation_library("", lib)
		
	if lib.has_animation("scene0"):
		lib.remove_animation("scene0")
	
	lib.add_animation("scene0", anim)
	print("Animation 'scene0' créée avec succès !")

# CORRECTION 4 : C'est cette fonction qui faisait planter le bouton avant
func _parse_arguments(args_string_array: Array) -> Array:
	var final_args: Array = []
	for raw_arg in args_string_array:
		# TRÈS IMPORTANT: On force la variable en String
		var arg_str: String = str(raw_arg)
		
		# Maintenant Godot accepte .split() car il sait que c'est du texte
		if "-" in arg_str and arg_str.length() > 1:
			var sub_parts = arg_str.split("-")
			for sp in sub_parts:
				var sp_str: String = str(sp)
				if sp_str.is_valid_float():
					final_args.append(sp_str.to_float())
		elif arg_str.is_valid_float():
			final_args.append(arg_str.to_float())
		else:
			final_args.append(arg_str)
	return final_args

func _find_path_for_node(target_name: String) -> NodePath:
	if not target_animation_player:
		printerr("AVERTISSEMENT: Noeud '%s' non trouvé (pas d'AnimationPlayer)." % target_name)
		return NodePath()
	
	var root = target_animation_player.get_parent()
	if not root:
		printerr("AVERTISSEMENT: Noeud '%s' non trouvé (pas de parent root)." % target_name)
		return NodePath()
		
	var node: Node = root.find_child(target_name, true, false)
	
	if node:
		return root.get_path_to(node)
	else:
		printerr("AVERTISSEMENT: Noeud '%s' non trouvé dans la scène. Piste ignorée." % target_name)
		return NodePath()
