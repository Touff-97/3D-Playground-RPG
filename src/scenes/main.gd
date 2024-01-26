extends Control

const MULTIPLAYER := preload("res://src/scenes/multiplayer_controller.tscn")
const CREATOR := preload("res://src/scenes/level_editor.tscn")

@onready var mode: Node = $Mode


func _on_singleplayer_mode_selected() -> void:
	var new_game := MULTIPLAYER.instantiate()
	mode.add_child(new_game, true)
	
	# Singleplayer instance of the multiplayer scene
	new_game.launch_singleplayer()


func _on_multiplayer_mode_selected() -> void:
	var new_game := MULTIPLAYER.instantiate()
	mode.add_child(new_game, true)


func _on_creator_mode_selected() -> void:
	var new_game := CREATOR.instantiate()
	mode.add_child(new_game, true)

