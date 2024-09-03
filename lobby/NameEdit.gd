extends LineEdit


func _ready():
	connect("text_changed", _on_text_changed)
	text = ServerSingleton.player_info["name"]
	
func _on_text_changed(new_text):
	if !new_text.is_empty():
		ServerSingleton.change_player_info.rpc(new_text, null)
