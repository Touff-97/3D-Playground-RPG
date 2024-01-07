extends Node

@export var player_scene : PackedScene

@onready var players: Node3D = $Players


func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(despawn_player)
	
	for i in GameManager.players:
		spawn_player(i.id)


func spawn_player(player_id: int) -> void:
	var new_player : Player = player_scene.instantiate()
	new_player.name = str(player_id)
	players.add_child(new_player, true)
	new_player.global_position = Vector3(randi() % 10 - 5, 1, randi() % 10 - 5)


func despawn_player(player_id: int):
	if not players.has_node(str(player_id)):
		return
	
	players.get_node(str(player_id)).queue_free()


func _exit_tree() -> void:
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(spawn_player)
	multiplayer.peer_disconnected.disconnect(despawn_player)
