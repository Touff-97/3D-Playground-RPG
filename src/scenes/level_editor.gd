extends GridMap

@onready var editor_view: Camera3D = $EditorView

var can_interact : bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and can_interact:
			place_tile()


func place_tile() -> void:
	var grid_coords := get_grid_coordinates()
	print(grid_coords)


func get_grid_coordinates() -> Vector3:
	var global_coords := get_global_coordinates()
	var local_coords : Vector3 = to_local(global_coords)
	
	return local_to_map(local_coords)


func get_global_coordinates() -> Vector3:
	return raycast_from_camera()["position"]


func raycast_from_camera() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var from = editor_view.project_ray_origin(mouse_pos)
	var to = from + editor_view.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_bodies = true
	
	var raycast_result = space.intersect_ray(ray_query)
	
	return raycast_result


func _on_ui_panel_mouse_entered() -> void:
	can_interact = false


func _on_ui_panel_mouse_exited() -> void:
	can_interact = true
