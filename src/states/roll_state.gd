extends RunState
class_name RollState

@export var time_to_roll : float = 1.0

var roll_timer : float = 0.0
var direction := Vector2(0.0, -1.0)


func enter() -> void:
	super()
	# When transitioning out of movement, disable moving condition
	animations.set("parameters/conditions/moving", false)
	roll_timer = time_to_roll


func process_input(event: InputEvent) -> StateComponent:
	return null


func process_physics(delta: float) -> StateComponent:
	roll_timer -= delta
	if roll_timer <= 0.0:
		# When rolling after a slide, disable stopped condition
		animations.set("parameters/conditions/stopped", false)
		# When transitioning out of a roll, disable rolling condition
		animations.set("parameters/conditions/rolling", false)
		if super.get_movement_input() != Vector2.ZERO:
			if super.get_crouch():
				### CROUCH ###
				# Condition to transition to crouching animation
				animations.set("parameters/conditions/crouching", true)
				# Transition to crouching animations
				return crouch_state
			### WALK ###
			# Condition to transition to movement animations
			animations.set("parameters/conditions/moving", true)
			# Transition to movement animations
			return move_state
		### IDLE ###
		# Condition to transition to movement animations
		animations.set("parameters/conditions/moving", true)
		# Transition to movement animations
		return idle_state
	
	return super(delta)


func get_movement_input() -> Vector2:
	return direction


func get_jump() -> bool:
	return false


func get_run() -> bool:
	return false
