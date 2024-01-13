extends MoveStateComponent
class_name RunStateComponent

@export_group("States")
@export var move_state : MoveStateComponent


func enter() -> void:
	super()
	parent.boost = 2.0


func exit() -> void:
	parent.boost = 1.0


func process_input(event: InputEvent) -> StateComponent:
	if input.wants_jump():
		if parent.is_on_floor():
			return jump_state
	
	if not input.wants_run():
		return move_state
	
	return null
