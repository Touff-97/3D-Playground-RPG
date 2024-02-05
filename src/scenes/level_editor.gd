extends GridMap

const ITEM = preload("res://src/scenes/level_editor_item.tscn")

@export var libraries : Array[MeshLibrary]
@export var selected_library : MeshLibrary
@export var selected_tile : int = -1
@export var tile_orientations : Array[int] = [0, 16, 10, 22]

@onready var editor_view: Camera3D = $ViewPivot/EditorView
@onready var interactible_zone_panel: Panel = $EditorUI/VBox/InteractibleZonePanel
@onready var category: ScrollContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Category
@onready var category_items: HBoxContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Category/Items
@onready var tiles: ScrollContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Tiles
@onready var tile_items: HBoxContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Tiles/Items
@onready var tile_preview: MeshInstance3D = $EditorUI/TilePreview

var can_interact : bool = false


func _ready() -> void:
	populate_categories()


func _input(event: InputEvent) -> void:
	if can_interact:
		if event is InputEventMouseMotion and selected_tile != -1:
			if event.is_action_pressed("stepped"):
				update_preview(true)
			else:
				update_preview(true)
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				place_tile()
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				remove_tile()
		
		if event.is_action_pressed("rotate_tile") and selected_tile != -1:
			var temp = tile_orientations.pop_front()
			tile_orientations.append(temp)
			tile_preview.rotate_y(PI / 2)
		
		if event.is_action_pressed("level_up"):
			editor_view.position.y += 1
		
		if event.is_action_pressed("level_down"):
			editor_view.position.y -= 1
	else:
		tile_preview.mesh = null


func update_preview(stepped: bool) -> void:
	var preview = selected_library.get_item_mesh(selected_tile)
	var preview_pos : Vector3
	
	if stepped:
		print("stepped")
		preview_pos = get_grid_coordinates()
		tile_preview.position = Vector3(preview_pos.x, preview_pos.y + 0.05, preview_pos.z) + \
								(preview.get_aabb().size / 2)
	else:
		preview_pos = screen_point_to_ray()["position"]
		tile_preview.position = Vector3(preview_pos.x, preview_pos.y + 0.05, preview_pos.z)
	
	tile_preview.mesh = preview


func populate_categories() -> void:
	for i in range(libraries.size()):
		var new_item = ITEM.instantiate()
		category_items.add_child(new_item)
		
		new_item.mesh_library = libraries[i]
		new_item.category_selected.connect(_on_category_selected)


func populate_tiles(library: MeshLibrary) -> void:
	tiles.show()
	
	for i in range(library.get_item_list().size()):
		var new_item = ITEM.instantiate()
		tile_items.add_child(new_item)
		
		new_item.item_id = i
		new_item.texture.texture_normal = library.get_item_preview(i)
		new_item.tile_selected.connect(_on_tile_selected)


func _on_category_selected(library: MeshLibrary) -> void:
	category.hide()
	
	clear_categories() # Reset the category tab
	
	selected_library = library
	mesh_library = selected_library
	
	populate_tiles(library)


func _on_tile_selected(id: int) -> void:
	selected_tile = id


func clear_categories() -> void:
	for i in category_items.get_children():
		i.category_selected.disconnect(_on_category_selected)
		remove_child(i)
		i.queue_free()


func clear_tiles() -> void:
	for i in tile_items.get_children():
		i.tile_selected.disconnect(_on_tile_selected)
		remove_child(i)
		i.queue_free()


func place_tile() -> void:
	if selected_tile != -1:
		var grid_coords := get_grid_coordinates()
		print(grid_coords)
		#var tween := get_tree().create_tween()
		#tween.tween_property(tile_preview, "scale", Vector3(0.9, 0.9, 0.9), 0.1)
		#tween.tween_property(tile_preview, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
		set_cell_item(grid_coords, selected_tile, tile_orientations[0])


func remove_tile() -> void:
	var grid_coords := get_grid_coordinates()
	set_cell_item(grid_coords, -1)


func get_grid_coordinates() -> Vector3:
	var global_coords : Vector3 = get_global_coordinates()
	var local_coords : Vector3 = to_local(global_coords)
	
	return local_to_map(local_coords)


func get_global_coordinates() -> Vector3:
	return screen_point_to_ray()["position"]


func screen_point_to_ray() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
	var from = editor_view.project_ray_origin(mouse_pos)
	var to = from + editor_view.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_bodies = true
	ray_query.collide_with_areas = true
	
	var raycast_result = space.intersect_ray(ray_query)
	
	return raycast_result


func _on_ui_panel_mouse_entered() -> void:
	can_interact = true


func _on_ui_panel_mouse_exited() -> void:
	can_interact = false


func _on_back_button_pressed() -> void:
	tiles.hide()
	clear_tiles()
	
	selected_library = null
	
	populate_categories()
	category.show()
	
