extends HBoxContainer

@export_group("Info", "info_")
@export var info_title : Label
@export var info_ip : Label
@export var info_count : Label

signal game_joined(ip)


func _on_join_pressed() -> void:
	game_joined.emit(info_ip.text)
