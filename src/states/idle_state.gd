extends StateComponent
class_name IdleState

@export_group("States")
@export var move_state : MoveState
@export var run_state : RunState
@export var jump_state : JumpState


func enter() -> void:
	super()
	parent.boost = 1.0
	
	animations.set("parameters/Jump/conditions/idle_jump", true)


func exit() -> void:
	super()
	animations.set("parameters/Jump/conditions/idle_jump", false)


func process_input(event: InputEvent) -> StateComponent:
	if get_movement_input() != Vector2.ZERO:
		return move_state
	
	if get_run():
		if get_movement_input() != Vector2.ZERO:
			return run_state
	
	if get_jump():
		if parent.is_on_floor():
			return jump_state
	
	return null


func process_physics(delta: float) -> StateComponent:
	parent.velocity.y -= gravity * delta
	
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.move_speed)
	parent.velocity.z = move_toward(parent.velocity.z, 0, parent.move_speed)
	
	parent.move_and_slide()
	
	if not parent.is_on_floor() and parent.velocity.y < 0:
		print("Falling")
	
	return null
