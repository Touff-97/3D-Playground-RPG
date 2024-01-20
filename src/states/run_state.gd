extends MoveState
class_name RunState

@export_group("States")
@export var move_state : MoveState


func enter() -> void:
	super()
	parent.boost = 2.0
	
	animations.set("parameters/Jump/conditions/run_jump", true)


func exit() -> void:
	super()
	animations.set("parameters/Jump/conditions/run_jump", false)


func process_input(event: InputEvent) -> StateComponent:
	if get_jump():
		if parent.is_on_floor():
			return jump_state
	
	if not get_run():
		return move_state
	
	return null
