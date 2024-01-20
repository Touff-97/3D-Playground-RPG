extends StateComponent
class_name JumpState

@export_group("States")
@export var idle_state : IdleState
@export var move_state : MoveState
@export var run_state : RunState

@export_group("Jump", "jump_")
@export var jump_force : float = 4.5

var jumped : bool = false


func enter() -> void:
	super()
	jumped = false


func process_physics(delta: float) -> StateComponent:
	parent.velocity.y -= gravity * delta
	
	# Let player move while in the air
	if parent.direction:
		parent.velocity.x = parent.direction.x * parent.move_speed * parent.boost
		parent.velocity.z = parent.direction.z * parent.move_speed * parent.boost
	
	parent.move_and_slide()
	
	if parent.is_on_floor() and jumped:
		if parent.direction:
			if get_run():
				return run_state
			return move_state
		return idle_state
	
	return null


# Gets called on a certain frame in the related animation
func jump() -> void:
	if not jumped:
		parent.velocity.y = jump_force
		jumped = true
		
		animations.set("parameters/conditions/jumping", false)
