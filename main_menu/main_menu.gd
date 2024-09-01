extends MarginContainer

@onready var name_edit = $VBoxContainer/NameEdit
@onready var join_button = $VBoxContainer/JoinButton
@onready var host_button = $VBoxContainer/HostButton
@onready var address_edit = $VBoxContainer/AddressEdit

const LOBBY_PATH = "res://lobby/lobby.tscn"

func _ready():
	name_edit.connect("text_changed", _on_name_changed)
	join_button.connect("button_up", _on_join_presssed)
	host_button.connect("button_up", _on_host_pressed)

func set_pname(new_name):
	ServerSingleton.player_info["name"] = new_name

func _on_name_changed(new_text):
	join_button.set_disabled(new_text.length() == 0)
	set_pname(new_text)
	
func _on_join_presssed():
	if name_edit.text.is_empty():
		set_pname("joined" + String.num_int64(randi_range(0,200)))
	ServerSingleton.join_game(address_edit.text)
	get_tree().change_scene_to_file(LOBBY_PATH)
	
func _on_host_pressed():
	if name_edit.text.is_empty():
		set_pname("host")
	ServerSingleton.create_game()
	get_tree().change_scene_to_file(LOBBY_PATH)
