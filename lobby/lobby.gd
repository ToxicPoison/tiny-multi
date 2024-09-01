extends Node

signal ready_status_updated

var ready_status = {}

func _ready():
	ServerSingleton.connect("player_connected", _on_player_connected)
	ServerSingleton.connect("player_disconnected", _on_player_disconnected)
	for p in ServerSingleton.players:
		ready_status[p] = true
		print(ready_status)
	ready_status_updated.emit()
	if is_multiplayer_authority():
		pass
	
func _on_player_connected(id, _info):
	ready_status[id] = true
	ready_status_updated.emit()
	
func _on_player_disconnected(id):
	ready_status.erase(id)
	ready_status_updated.emit()

@rpc("any_peer", "call_local")
func set_player_ready(id, status):
	ready_status[id] = status
	ready_status_updated.emit()

func _on_ready_button_toggled(toggled_on):
	set_player_ready.rpc(multiplayer.get_unique_id(), toggled_on)


func _on_disconnect_button_pressed():
	ServerSingleton.leave_game(0)


func _on_start_button_pressed():
	ServerSingleton.load_scene.rpc("res://game/game.tscn")
