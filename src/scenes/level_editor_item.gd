extends Panel
class_name EditorItem

@export var item_id : int = -1
@export var mesh_library : Resource:
	set(new_value):
		mesh_library = new_value
		
		texture.texture_normal = mesh_library.get_item_preview(0)

@export var texture: TextureButton

signal category_selected(library)
signal tile_selected(id)


func _on_item_pressed() -> void:
	if mesh_library:
		print("Is category")
		emit_signal("category_selected", mesh_library)
	else:
		print("Is tile")
		emit_signal("tile_selected", item_id)


func _on_texture_mouse_entered() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(texture, "scale", Vector2(1.1, 1.1), 0.1)


func _on_texture_mouse_exited() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(texture, "scale", Vector2(1.0, 1.0), 0.1)


func _on_texture_button_down() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(texture, "scale", Vector2(0.75, 0.75), 0.1)


func _on_texture_button_up() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(texture, "scale", Vector2(1.1, 1.1), 0.1)
