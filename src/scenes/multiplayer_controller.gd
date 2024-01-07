extends Control

@export_group("Server", "server_")
@export var server_ip_address : String = "localhost"
@export var server_port : int = 8910
@export_range(0, 100, 1) var server_max_clients : int = 10
@export var server_is_started : bool = false
@export_group("Client", "client_")
@export var client_name : String = "Client"
@export_group("Level", "level_")
@export var level_world : Node3D

@onready var server_browser: Control = $Margin/VBox/ServerBrowser
@onready var queue_popup: PopupPanel = $QueuePopup
@onready var level: Node = $Level

var peer : ENetMultiplayerPeer


func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	if OS.get_cmdline_args().has("dedicated_server"):
		print("Is dedicated server")
		host_game()
		server_browser.setup_broadcast("%s's Server" % client_name)


# Player connection functions that run on all clients
func on_peer_connected(player_id: int) -> void:
	print("Peer %s has connected" % str(player_id))
	
	var player_name: String
	for i in GameManager.players:
		if i.id == player_id:
			player_name = i.name


func on_peer_disconnected(player_id: int) -> void:
	print("Peer %s has disconnected" % str(player_id))
	
	if player_id == 1:
		rpc("disconnect_players")
	
	# Stop tracking data for disconnected players
	for i in GameManager.players:
		if i.id == player_id:
			GameManager.players.erase(i)


# Server connection functions that run only on client-side
func _on_connected_to_server() -> void:
	print("Connected to server succesfully")
	rpc_id(1, "send_player_information", client_name, multiplayer.get_unique_id())
	if not multiplayer.is_server():
		rpc_id(1, "request_start_game", multiplayer.get_unique_id())


func _on_connection_failed() -> void:
	printerr("Connection failed!")


func _on_client_name_text_changed(new_text: String) -> void:
	client_name = new_text


func _on_host_button_down() -> void:
	print("Host button down")
	host_game()
	send_player_information(client_name, 1)
	server_browser.setup_broadcast("%s's Server" % client_name)


func _on_start_button_down() -> void:
	rpc("start_game")
	server_is_started = true


func host_game() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(server_port, server_max_clients)
	
	if error != OK:
		printerr("Hosting failed with error %s" % str(error))
		return
	
	# Data compression algorithm
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	print("Wainting for players...")


func join_game(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, server_port)
	
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	print("Joining game...")


@rpc("any_peer", "reliable")
func request_start_game(player_id: int) -> void:
	if server_is_started:
		print("Entering existing game")
		rpc_id(player_id, "start_game")
	else:
		print("Waiting to start game")
		rpc_id(player_id, "wait_for_game")


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	hide()
	
	if multiplayer.is_server():
		change_level.call_deferred(ResourceLoader.load("res://src/scenes/world.tscn", "PackedScene"))


func change_level(scene: PackedScene) -> void:
	for i in level.get_children():
		remove_child(i)
		i.queue_free()
	
	var new_scene = scene.instantiate()
	level.add_child(new_scene, true)
	
	level_world = new_scene


@rpc("any_peer", "call_local", "reliable")
func wait_for_game() -> void:
	queue_popup.popup()


@rpc("any_peer")
func send_player_information(player_name: String, player_id) -> void:
	var player_info := PlayerInfo.new()
	player_info.name = player_name
	player_info.id = player_id
	
	if not GameManager.players.has(player_info):
		GameManager.players.append(player_info)
	
	if multiplayer.is_server():
		for i in GameManager.players:
			rpc("send_player_information", i.name, i.id)


@rpc("any_peer", "call_local")
func disconnect_players() -> void:
	GameManager.players.clear()
	level_world.queue_free()
	show()


@rpc("any_peer")
func request_disconnect_player(player_id: int) -> void:
	rpc("disconnect_player", player_id)


@rpc()
func disconnect_player(player_id: int) -> void:
	peer.disconnect_peer(player_id)


func _on_server_browser_game_joined(ip: String) -> void:
	join_game(ip)


func _on_queue_popup_close_requested() -> void:
	rpc_id(1, "request_disconnect_player", multiplayer.get_unique_id())
