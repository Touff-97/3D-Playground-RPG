extends GridMap

const ITEM = preload("res://src/scenes/level_editor_item.tscn")

@export var libraries : Array[MeshLibrary]
@export var selected_library : MeshLibrary
@export var selected_tile : int = -1

@onready var editor_view: Camera3D = $EditorView
@onready var interactible_zone_panel: Panel = $EditorUI/VBox/InteractibleZonePanel
@onready var category: ScrollContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Category
@onready var category_items: HBoxContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Category/Items
@onready var tiles: ScrollContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Tiles
@onready var tile_items: HBoxContainer = $EditorUI/VBox/TopPanel/Margin/HBox/Tiles/Items
@onready var tile_preview: TextureRect = $EditorUI/TilePreview

var can_interact : bool = false


func _ready() -> void:
	populate_categories()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and selected_tile != -1:
		get_grid_coordinates()
		update_preview(event.position)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and can_interact:
			place_tile()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed() and can_interact:
			remove_tile()


func update_preview(pos: Vector2) -> void:
	var preview = selected_library.get_item_preview(selected_tile)
	tile_preview.texture = preview
	tile_preview.position = pos - (preview.get_size() / 2)


func populate_categories() -> void:
	for i in range(libraries.size()):
		var new_item = ITEM.instantiate()
		category_items.add_child(new_item)
		
		new_item.mesh_library = libraries[i]
		new_item.category_selected.connect(_on_category_selected)


func clear_categories() -> void:
	for i in category_items.get_children():
		i.category_selected.disconnect(_on_category_selected)
		remove_child(i)
		i.queue_free()


func _on_category_selected(library: MeshLibrary) -> void:
	print("Selected library")
	category.hide()
	#clear_categories() # Reset the category tab
	selected_library = mesh_library
	
	populate_tiles(library)


func populate_tiles(library: MeshLibrary) -> void:
	tiles.show()
	
	for i in range(library.get_item_list().size()):
		var new_item = ITEM.instantiate()
		tile_items.add_child(new_item)
		
		new_item.item_id = i
		new_item.texture.texture_normal = library.get_item_preview(i)
		new_item.tile_selected.connect(_on_tile_selected)


func _on_tile_selected(id: int) -> void:
	selected_tile = id


func place_tile() -> void:
	var grid_coords := get_grid_coordinates()
	print(grid_coords)
	if selected_tile != -1:
		set_cell_item(grid_coords, selected_tile)


func remove_tile() -> void:
	var grid_coords := get_grid_coordinates()
	set_cell_item(grid_coords, -1)


func get_grid_coordinates() -> Vector3:
	var global_coords : Vector3 = get_global_coordinates()
	var local_coords : Vector3 = to_local(global_coords)
	
	print(local_to_map(local_coords))
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
	ray_query.collide_with_areas = true
	
	var raycast_result = space.intersect_ray(ray_query)
	
	return raycast_result


func _on_ui_panel_mouse_entered() -> void:
	can_interact = true


func _on_ui_panel_mouse_exited() -> void:
	can_interact = false
