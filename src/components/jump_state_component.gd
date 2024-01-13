extends StateComponent
class_name JumpStateComponent

@export_group("States")
@export var idle_state : IdleStateComponent
@export var move_state : MoveStateComponent
@export var run_state : RunStateComponent

@export_group("Jump", "jump_")
@export var jump_force : float = 4.5

var jumped : bool = false


func exit() -> void:
	animations.set("parameters/conditions/%s" % animation_condition, false)
	jumped = false


func process_physics(delta: float) -> StateComponent:
	parent.velocity.y -= gravity * delta
	
	# Let player move while in the air
	if parent.direction:
		parent.velocity.x = parent.direction.x * parent.move_speed * parent.boost
		parent.velocity.z = parent.direction.z * parent.move_speed * parent.boost
	
	parent.move_and_slide()
	
	if parent.is_on_floor() and jumped:
		print("Has jumped and landed")
		if parent.direction:
			if get_run():
				return run_state
			return move_state
		return idle_state
	
	return null


func jump() -> void:
	if not jumped:
		print("Jumped")
		parent.velocity.y = jump_force
		jumped = true
