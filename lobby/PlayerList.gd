extends RichTextLabel

var base_text : String = "Players:\n"
@onready var lobby = get_tree().get_current_scene()
const NOT_READY_IMG = "res://lobby/not_ready.png"
const READY_IMG = "res://lobby/ready.png"


func update_list():
	text = "Players:"
	for p in ServerSingleton.players:
		var color = "orange"
		var status_icon = NOT_READY_IMG
		if lobby.ready_status[p]:
			color = "cornflower_blue"
			status_icon = READY_IMG
		text += "\n[color=" + color + "][img]" + status_icon + "[/img]   " + ServerSingleton.players[p]["name"] + "[/color]"

func _ready():
	#ServerSingleton.connect("player_connected", _on_player_connected)
	#ServerSingleton.connect("player_disconnected", _on_player_disconnected)
	ServerSingleton.connect("player_info_modified", _on_somebodys_info_changed)
	#update_list()
	
#func _on_player_connected(peer_id, player_info):
	#update_list()
#
#func _on_player_disconnected(peer_id):
	#update_list()

func _on_somebodys_info_changed():
	update_list()

func _on_lobby_ready_status_updated():
	update_list()
