extends StateComponent
class_name IdleStateComponent

@export_group("States")
@export var move_state : MoveStateComponent
@export var run_state : RunStateComponent
@export var jump_state : JumpStateComponent

var last_animation := Vector2.ZERO


func process_input(event: InputEvent) -> StateComponent:
	if get_jump():
		if parent.is_on_floor():
			return jump_state
	
	if get_movement_input():
		return move_state
	
	if get_run():
		return run_state
	
	return null


func process_physics(delta: float) -> StateComponent:
	parent.velocity.y -= gravity * delta
	
	var lerp_animation = clamp(lerp(last_animation, get_movement_input() * parent.boost, 0.2), Vector2(-2, -2), Vector2(2, 2))
	animations.set("parameters/Movement/blend_position", lerp_animation)
	last_animation = lerp_animation
	parent.move_animation = lerp_animation
	
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.move_speed)
	parent.velocity.z = move_toward(parent.velocity.z, 0, parent.move_speed)
	
	parent.move_and_slide()
	
	if not parent.is_on_floor() and parent.velocity.y < 0:
		print("Falling")
	
	return null
