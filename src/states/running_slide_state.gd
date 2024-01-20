extends RunState
class_name RunningSlideState

@export var time_to_slide : float = 1.0

@export_group("States")
@export var roll_state : RollState

var slide_timer : float = 0.0
var direction := Vector2(0.0, -1.0)


func enter() -> void:
	super()
	# When transitioning out of movement, disable moving condition
	animations.set("parameters/conditions/moving", false)
	slide_timer = time_to_slide
	parent.boost = 3.0


func process_input(event: InputEvent) -> StateComponent:
	return null


func process_physics(delta: float) -> StateComponent:
	slide_timer -= delta
	if slide_timer <= 0.0:
		# When finished sliding, disable sliding condition
		animations.set("parameters/conditions/sliding", false)
		
		if super.get_movement_input() != Vector2.ZERO:
			### MOVE ###
			# Condition to transition to movement animations
			animations.set("parameters/conditions/moving", true)
			# Transition to movement animations
			### RUN ###
			if super.get_run():
				return run_state
			### WALK ###
			return move_state
		### IDLE ###
		# Condition to transition to roll/stumble animation
		animations.set("parameters/conditions/stopped", true)
		# Transition to roll/stumble animation
		return roll_state
	
	return super(delta)


func get_movement_input() -> Vector2:
	return direction


func get_jump() -> bool:
	return false


func get_crouch() -> bool:
	return false
