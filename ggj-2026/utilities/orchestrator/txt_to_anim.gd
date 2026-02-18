@tool
extends Node

@export_file("*.json") var timeline_file : String
@export var animation_player: AnimationPlayer

@export_tool_button("Générer Animation")
var generate_button := generate_animation

var tracks := {}

# -----------------------------------------------------

func generate_animation() -> void:
	if not _validate():
		return

	tracks.clear()
	var timeline : Array = _load_json_timeline(timeline_file)

	var anim : Animation = Animation.new()
	anim.resource_name = "scene_generated"
	anim.length = 60.0

	for entry in timeline:
		_process_entry(anim, entry)

	_apply_animation(anim)
	print("✅ Animation générée avec %d entrées" % timeline.size())

# -----------------------------------------------------

func _validate() -> bool:
	if not FileAccess.file_exists(timeline_file):
		printerr("Timeline JSON manquante")
		return false
	if not animation_player:
		printerr("AnimationPlayer manquant")
		return false
	return true

# -----------------------------------------------------

func _load_json_timeline(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("Impossible d'ouvrir le JSON :", path)
		return []

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		printerr("JSON invalide :", json.get_error_message())
		return []

	var result: Dictionary = json.data
	var timeline_data: Array = result.get("timeline", [])
	return timeline_data

# -----------------------------------------------------

func _process_entry(anim: Animation, entry) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		return
	
	var entry_dict: Dictionary = entry
	for entry_type in entry_dict.keys():
		print("Processing entry type: %s" % entry_type)
		var data: Dictionary = entry_dict[entry_type]
		_process_command(anim, entry_type, data)

func _process_command(anim: Animation, cmd_type: String, data: Dictionary) -> void:
	var begin_time: float = data.get("begin_time", 0.0)
	var duration: float = data.get("duration", 1.0)

	match cmd_type:
		"MOVE":
			var actor: String = data.get("actor", "")
			var plan: int = int(data.get("plan", 0))
			var noeud: int = int(data.get("noeud", 0))
			_add_method_key(anim, actor, begin_time, "move_to", [plan, noeud, duration])
		
		"INCIDENT_ACTIVATION":
			var actor: String = data.get("actor", "")
			_add_method_key(anim, actor, begin_time, "activate", [duration])
		
		"INCIDENT_BREAK":
			var actor: String = data.get("actor", "")
			_add_method_key(anim, actor, begin_time, "activate", [duration])
		
		"INCIDENT_INTRU":
			var intru: String = data.get("actor", "")
			_add_method_key(anim, intru, begin_time, "activate", [duration])
		
		"ANIMATION":
			var actor: String = data.get("actor", "")
			_add_method_key(anim, actor, begin_time, "anim", [data.get("animation", ""), data.get("duration", 1.0)])
		
		"AUDIO":
			var audio_file: String = data.get("audio_file", "")
			_add_method_key(anim, "AudioReplicPlayer", begin_time, "play_audio", [audio_file])
		_:
			printerr("Type de commande inconnu: ", cmd_type)

func _add_method_key(anim: Animation, target: String, time: float, method: String, args: Array) -> void:
	if target.is_empty():
		printerr("Target vide pour méthode: ", method)
		return
	
	var track :int = _get_track(anim, target)
	if track == -1:
		printerr("Track introuvable pour: ", target)
		return

	anim.track_insert_key(track, time, {
		"method": method,
		"args": args
	})

# -----------------------------------------------------

func _get_track(anim: Animation, target: String) -> int:
	if target in tracks:
		return tracks[target]

	var node_path : NodePath = _find_node_path(target)
	if node_path.is_empty():
		return -1

	var idx : int = anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(idx, node_path)
	tracks[target] = idx
	return idx

# -----------------------------------------------------

func _apply_animation(anim: Animation) -> void:
	# Créer le dossier si nécessaire
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("animations"):
		dir.make_dir("animations")
	
	var anim_path : String = "res://animations/scene0.tres"
	var lib_path : String  = "res://animations/scene_library.tres"
	
	# Utiliser take_over_path pour éviter les conflits de ressource
	anim.take_over_path(anim_path)
	ResourceSaver.save(anim, anim_path)
	
	# Créer une nouvelle library (évite les problèmes de cache)
	var lib : AnimationLibrary = AnimationLibrary.new()
	lib.add_animation("scene0", anim)
	lib.take_over_path(lib_path)
	ResourceSaver.save(lib, lib_path)
	
	# Assigner au player
	if animation_player.has_animation_library(""):
		animation_player.remove_animation_library("")
	animation_player.add_animation_library("", lib)
	
	print("💾 Animation sauvegardée: ", anim_path)

# -----------------------------------------------------

func _find_node_path(node_name: String) -> NodePath:
	var root = animation_player.get_parent()
	var node : Node = root.find_child(node_name, true, false)
	return root.get_path_to(node) if node else NodePath()
