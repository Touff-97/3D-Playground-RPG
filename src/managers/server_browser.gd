extends Control

@export_group("Broadcast", "bc_")
@export var bc_broadcast_address : String = "192.168.1.255"
@export var bc_broadcast_port : int = 8911
@export var bc_listen_port : int = 8912

@export_group("Room", "room_")
@export var room_server_item : PackedScene
@export var room_info : Dictionary = {
	"name": "server",
	"player_count": 0
}

@onready var broadcast_timer: Timer = $BroadcastTimer
@onready var listen_port_label: Label = $Browser/ListenPortLabel
@onready var server_list: VBoxContainer = $Browser/Servers/Margin/VBox/Scroll/ServerList

var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP

signal server_found(ip, port, server_info)
signal server_updated(ip, port, server_info)
signal game_joined(ip)


func _ready() -> void:
	print(OS.get_cmdline_args())
	if not OS.get_cmdline_args().has("dedicated_server"):
		setup_listen()
	else:
		set_process(false)


func _process(delta: float) -> void:
	if listener.get_available_packet_count() > 0:
		var server_ip = listener.get_packet_ip()
		var server_port = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_ascii() # Match the buffer chosen for packets when broadcasting
		
		room_info = JSON.parse_string(data)
		
		print("Server with IP: %s:%s has following info attached: %s" % [server_ip, server_port, room_info])
		
		for i in server_list.get_children():
			if i.name == room_info.name:
				server_updated.emit(server_ip, server_port, room_info)
				
				i.info_title.text = room_info.name
				i.info_ip.text = server_ip
				i.info_count.text = str(room_info.player_count)
				return
			
		var current_info = room_server_item.instantiate()
		current_info.name = room_info.name
		current_info.info_title.text = room_info.name
		current_info.info_ip.text = server_ip
		current_info.info_count.text = str(room_info.player_count)
		server_list.add_child(current_info, true)
		current_info.game_joined.connect(join_by_ip)
		
		server_found.emit(server_ip, server_port, room_info)


func setup_broadcast(room_name: String) -> void:
	room_info.name = room_name
	room_info.player_count = GameManager.players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(bc_broadcast_address, bc_listen_port)
	
	var ok = broadcaster.bind(bc_broadcast_port)
	
	if ok == OK:
		print("Bound to broadcast port %s successful" % str(bc_broadcast_port))
	else:
		print("Failed to bind to broadcast port")
	
	broadcast_timer.start()


func setup_listen() -> void:
	listener = PacketPeerUDP.new()
	
	var error = listener.bind(bc_listen_port)
	
	if error == OK:
		print("Bound to listen port %s successful" % str(bc_listen_port))
		listen_port_label.text = "Bound to listen port: true"
	else:
		print("Failed to bind to listen port")
		listen_port_label.text = "Bound to listen port: false"
	


func join_by_ip(ip: String) -> void:
	game_joined.emit(ip)


func clean_up() -> void:
	listener.close()
	
	broadcast_timer.stop()
	
	if broadcaster:
		broadcaster.close()


func _exit_tree() -> void:
	clean_up()


func _on_broadcast_timer_timeout() -> void:
	print("Broadcasting game...")
	
	room_info.player_count = GameManager.players.size()
	
	var data = JSON.stringify(room_info)
	var packet = data.to_ascii_buffer() # Based on the characters on info
	
	if broadcaster:
		broadcaster.put_packet(packet)
