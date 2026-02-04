extends Node

signal camera_ready(camera: Camera3D)
var camera: Camera3D

func set_camera(camera_to_set: Camera3D) -> void:
	camera = camera_to_set
	camera_ready.emit(camera) # Notify anyone waiting

func get_camera() -> Camera3D:
	if camera == null:
		# Execution pauses here until 'camera_ready' is emitted
		camera = await camera_ready
	return camera
