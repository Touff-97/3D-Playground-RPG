extends StateComponent
class_name MoveStateComponent

@export_group("States")
@export var idle_state : IdleStateComponent
@export var run_state : RunStateComponent
@export var crouch_state : CrouchStateComponent
@export var jump_state : JumpStateComponent


func enter() -> void:
	super()
	parent.boost = 1.0
	setup_jump()


func process_input(event: InputEvent) -> StateComponent:
	if get_run():
		return run_state
	
	if get_crouch():
		return crouch_state
	
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


func setup_jump() -> void:
	animations.set("parameters/Jump/conditions/idle_jump", false)
	animations.set("parameters/Jump/conditions/walk_jump", true)
	animations.set("parameters/Jump/conditions/run_jump", false)
