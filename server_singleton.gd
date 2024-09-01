extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal players_loaded_in_new_scene
signal player_info_modified(player_info)

const PORT := 7707
const DEFAULT_SERVER_IP := "127.0.0.1"
const MAX_CONNECTIONS := 5

const MAIN_MENU_PATH = "res://main_menu/main_menu.tscn"

#info for each player (keys are player IDs)
var players = {}
#local player info
var player_info = {"name":"Name", "team":0}
var players_loaded := 0
var kick_reason : String = ""
var kick_reasons = ["Peacefully disconnected from server", "Server has been stopped", "Kicked from server by authority"]

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address := ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	
func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

#ServerSingleton.load_scene.rpc(filepath) to change scene
@rpc("call_local", "reliable")
func load_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)

#Called by each peer when they have loaded a new scene (in that scene's ready function i presume)
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			players_loaded_in_new_scene.emit()
			players_loaded = 0

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	
#Send MY info to the player that just joined
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	
func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

@rpc("any_peer", "call_local", "reliable")
func change_player_info(new_name):
	var sender_id := multiplayer.get_remote_sender_id()
	var my_id := multiplayer.get_unique_id()
	if sender_id == my_id:
		player_info["name"] = new_name
	players[sender_id] = {"name":new_name}
	player_info_modified.emit()

func leave_game(reason : int):
	var id := multiplayer.get_unique_id()
	multiplayer.multiplayer_peer = null
	print(String.num_int64(id) + " has disconnected.")
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
	players.clear()
	kick_reason = kick_reasons[reason]

@rpc("authority", "call_remote", "reliable")
func kick_player(reason : int):
	leave_game(reason)
	
