extends Node2D

var player_scene := preload("res://player/player.tscn")
@onready var player_root = $Players
@onready var crosshair = $UILayer/UI/Crosshair
@onready var camera = $Camera2D


func _ready():
	ServerSingleton.player_loaded.rpc_id(1)
	if ServerSingleton.is_multiplayer_authority(): 
		ServerSingleton.connect("players_loaded_in_new_scene", start_game)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	
func start_game():
	setup.rpc()
	
@rpc("authority", "call_local", "reliable")
func setup():
	spawn_players()
	
func spawn_players():
	for player in ServerSingleton.players:
		var new_player = player_scene.instantiate()
		new_player.set_name(String.num_int64(player))
		player_root.add_child(new_player)
		new_player.set_multiplayer_authority(player)
		if player == ServerSingleton.get_multiplayer_authority():
			new_player.position = Vector2(100.0, 0.0)
			new_player.set_modulate(Color.GREEN_YELLOW)
			print("ICE CREAM")
			print(player)
	
	
func _input(event):
	if event is InputEventMouseMotion:
		crosshair.position = event.position


