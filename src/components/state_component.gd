extends Component
class_name StateComponent

@export var animation_condition : String

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") 
# Dependencies
var parent : CharacterBody3D
var animations : AnimationTree
var input : InputComponent


func enter() -> void:
	parent.state_label.text = name
	if animation_condition != "":
		animations.set("parameters/conditions/%s" % animation_condition, true)


func exit() -> void:
	pass


func process_input(event: InputEvent) -> StateComponent:
	return null


func process_physics(delta: float) -> StateComponent:
	return null


func process_frame(delta: float) -> StateComponent:
	return null


func get_movement_input() -> Vector2:
	return input.get_movement_direction()


func get_run() -> bool:
	return input.wants_run()


func get_crouch() -> bool:
	return input.wants_crouch()


func get_jump() -> bool:
	return input.wants_jump()


func setup_jump() -> void:
	pass
