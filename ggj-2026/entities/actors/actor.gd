extends Node
class_name Actor

@onready var actor_animation_player: AnimationPlayer = $AnimationPlayer
@onready var actor_manager: ActorManager = get_parent()
var is_actor_moving: bool = false

# Références pour la pause
var current_tween: Tween
var paused_animation: String = ""
var animation_timer: Timer


func anim(anim_name: String, anim_duration: float) -> void:
	actor_animation_player.play(anim_name)
	if !animation_timer:
		animation_timer = Timer.new()
		add_child(animation_timer)
		animation_timer.one_shot = true
	animation_timer.wait_time = anim_duration
	animation_timer.timeout.connect(on_animation_timer_timeout)
	animation_timer.start()

func pause_actor_timer() -> void:
	if animation_timer:
		animation_timer.paused = true

func resume_actor_timer() -> void:
	if animation_timer:
		animation_timer.paused = false

func on_animation_timer_timeout() -> void:
	actor_animation_player.stop()

func move_to(plan: int, node: int, duration: float) -> void:
	SignalBus.ask_to_move.emit(self, duration, plan, node)
