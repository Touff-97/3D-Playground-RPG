extends InputComponent
class_name PlayerInputComponent

signal mouse_moved(event)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		emit_signal("mouse_moved", event)


func get_movement_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func wants_run() -> bool:
	return Input.is_action_pressed("run")


func wants_crouch() -> bool:
	return Input.is_action_pressed("crouch")


func wants_jump() -> bool:
	return Input.is_action_just_pressed("jump")
