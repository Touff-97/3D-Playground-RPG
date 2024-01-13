extends StateComponent
class_name MoveStateComponent

@export_group("States")
@export var idle_state : IdleStateComponent
@export var run_state : RunStateComponent
@export var jump_state : JumpStateComponent

var last_animation := Vector2.ZERO


func process_input(event: InputEvent) -> StateComponent:
	if get_jump():
		if parent.is_on_floor():
			return jump_state
	
	if get_run():
		return run_state
	
	return null


func process_physics(delta: float) -> StateComponent:
	parent.velocity.y -= gravity * delta
	
	var lerp_animation = clamp(lerp(last_animation, get_movement_input() * parent.boost, 0.2), Vector2(-2, -2), Vector2(2, 2))
	animations.set("parameters/Movement/blend_position", lerp_animation)
	last_animation = lerp_animation
	parent.move_animation = lerp_animation
	
	if parent.direction:
		parent.velocity.x = parent.direction.x * parent.move_speed * parent.boost
		parent.velocity.z = parent.direction.z * parent.move_speed * parent.boost
	else:
		return idle_state
	
	parent.move_and_slide()
	
	if not parent.is_on_floor() and parent.velocity.y < 0:
		print("Falling")
	
	return null
