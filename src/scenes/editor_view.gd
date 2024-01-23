extends Camera3D

var prev_pos : Vector2 = Vector2.ZERO
var can_pan : bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		get_viewport().set_input_as_handled()
		if event.is_pressed():
			prev_pos = event.position
			can_pan = true
		else:
			can_pan = false
	elif event is InputEventMouseMotion and can_pan:
		get_viewport().set_input_as_handled()
		position = Vector3(prev_pos.x - event.position.x, 0, prev_pos.y - event.position.y)
		print(prev_pos)
		
		prev_pos = event.position
