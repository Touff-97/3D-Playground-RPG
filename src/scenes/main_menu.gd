extends MarginContainer

signal singleplayer_mode_selected
signal multiplayer_mode_selected
signal creator_mode_selected


func _on_singleplayer_mode_pressed() -> void:
	print("Singleplayer button down")
	hide()
	emit_signal("singleplayer_mode_selected")
	
	# If you want to open up this session to multiplayer, you have to:
	# 1. Start broadcasting the server
	# 2. Set server_is_started to true


func _on_multiplayer_mode_pressed() -> void:
	hide()
	emit_signal("multiplayer_mode_selected")


func _on_create_mode_pressed() -> void:
	hide()
	emit_signal("creator_mode_selected")
	# TODO:
	# 1. Start the level editor tool
	# 1.a. Will it be local or multiplayer connection?
	# 1.b. Hide menu, show world select window (world is a collection of levels)
	# 1.c. Select existing world or create new world
	# 2. Let player build
	# 2.a. On world, show UI to place down tiles, entities and events
	# 3. Let player save the level
	# 4. Let the player playtest
	# 4.a. Seamlessly allow to play the scene and go back to build mode
	# 5. Let the player finalize the build, then play it on singleplayer or share it
	pass
