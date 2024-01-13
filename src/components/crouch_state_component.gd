extends MoveStateComponent
class_name CrouchStateComponent

@export_group("States")
@export var move_state : MoveStateComponent
@export var roll_state : RollStateComponent


func enter() -> void:
	super()
	# When transitioning out of movement, disable moving condition
	animations.set("parameters/conditions/moving", false)
	parent.boost = 0.5


func exit() -> void:
	# When transitioning out of crouch, disable crouching condition
	animations.set("parameters/conditions/crouching", false)


func process_input(event: InputEvent) -> StateComponent:
	if not get_crouch():
		### MOVE ###
		# Condition to transition to movement animations
		animations.set("parameters/conditions/moving", true)
		if get_movement_input() != Vector2.ZERO:
			return move_state
		return idle_state
	
	if get_jump():
		if parent.is_on_floor():
			return roll_state
	
	return null
