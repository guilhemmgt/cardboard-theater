@tool
extends Node
class_name SpectatorManager

const ONE_SPECTOR = preload("uid://wqndrrl2ra2q")

@export var min_spectator_to_react : int = 1
@export var max_spectator_to_react : int = 3

@export_group("Spectators Plot")
@export var space_between_spectator : float
@export var number_spectators_wanted : int
@export_tool_button("Plot Spectators") var create_spectators_button = create_spectators
var spectators_array : Array[Spectator]
var spectators_array_ready_size: int

@export_group("Leave anim")
@export var min_time_between : float
@export var max_time_between : float

func _ready() -> void:
	for ch in get_children():
		if ch is Spectator:
			spectators_array.append(ch)
	spectators_array_ready_size = spectators_array.size()
	print("spectator array size : ", spectators_array_ready_size)

func create_spectators() -> void:
	for ch in get_children():
		ch.queue_free()
	spectators_array.clear()
	for left in [0,1]:
		for i in range(left, int(number_spectators_wanted/2.0)+1):
			var ch:Spectator = ONE_SPECTOR.instantiate()
			self.add_child(ch)
			ch.owner = self
			ch.global_position.x = i*space_between_spectator*(2*left-1)

func react_to_intruder(intruder_name: String):
	for _i in range(randi_range(min_spectator_to_react, max_spectator_to_react)):
		var speaking_spectator : Spectator = spectators_array.pick_random() 
		speaking_spectator.react(intruder_name)
		
func update_life(current_life:int, max_life:int):
	var number_spectators_to_leave :int = int(spectators_array_ready_size/float(max_life))
	print("num spectators leave : ",number_spectators_to_leave)
	if current_life == 0:
		number_spectators_to_leave = spectators_array.size()
	
	for i in range(number_spectators_to_leave):
		var leaving_spectator : Spectator = spectators_array.pick_random()
		leaving_spectator.leave()
		spectators_array.erase(leaving_spectator)
		await get_tree().create_timer(randf_range(min_time_between, max_time_between)).timeout
		
	
