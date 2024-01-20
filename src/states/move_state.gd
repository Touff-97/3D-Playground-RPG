extends StateComponent
class_name MoveState

@export_group("States")
@export var idle_state : IdleState
@export var run_state : RunState
@export var jump_state : JumpState


func enter() -> void:
	super()
	parent.boost = 1.0
	
	animations.set("parameters/Jump/conditions/walk_jump", true)


func exit() -> void:
	super()
	animations.set("parameters/Jump/conditions/walk_jump", false)


func process_input(event: InputEvent) -> StateComponent:
	if get_run():
		return run_state
	
	if get_jump():
		if parent.is_on_floor():
			return jump_state
	
	return null


func process_physics(delta: float) -> StateComponent:
	parent.velocity.y -= gravity * delta
	
	parent.move_direction = get_movement_input()
	
	if parent.direction:
		parent.velocity.x = parent.direction.x * parent.move_speed * parent.boost
		parent.velocity.z = parent.direction.z * parent.move_speed * parent.boost
	else:
		return idle_state
	
	parent.move_and_slide()
	
	if not parent.is_on_floor() and parent.velocity.y < 0:
		print("Falling")
	
	return null
