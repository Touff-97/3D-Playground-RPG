extends MoveStateComponent
class_name RunStateComponent

@export_group("States")
@export var move_state : MoveStateComponent
@export var slide_state : RunningSlideStateComponent


func enter() -> void:
	super()
	parent.boost = 2.0
	setup_jump()


func process_input(event: InputEvent) -> StateComponent:
	if get_jump():
		if parent.is_on_floor():
			return jump_state
	
	if not get_run():
		return move_state
	
	if get_crouch():
		return slide_state
	
	return null


func setup_jump() -> void:
	animations.set("parameters/Jump/conditions/idle_jump", false)
	animations.set("parameters/Jump/conditions/walk_jump", false)
	animations.set("parameters/Jump/conditions/run_jump", true)
