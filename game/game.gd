extends Node2D

var player_scene := preload("res://player/player.tscn")
var player_root : Object
var level_scene : PackedScene = preload("res://level/platform_basic.tscn")
var level
var spawnpoints = [null, null]

@onready var crosshair = $UILayer/Crosshair
@onready var camera = $Camera2D
@onready var ui = $UILayer

var local_player : Object

func _ready():
	ServerSingleton.player_loaded.rpc_id(1)
	if ServerSingleton.is_multiplayer_authority(): 
		ServerSingleton.connect("players_loaded_in_new_scene", start_game)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	
func start_game():
	setup.rpc()
	
@rpc("authority", "call_local", "reliable")
func setup():
	insert_level()
	spawn_players()
	
func insert_level():
	level = level_scene.instantiate()
	add_child(level)
	player_root = level
	for spawnpoint in get_tree().get_nodes_in_group("spawn"):
		spawnpoints[spawnpoint.team] = spawnpoint
	
func spawn_players():
	for player in ServerSingleton.players:
		var team = ServerSingleton.players[player]["team"]
		var new_player = player_scene.instantiate()
		new_player.team = team
		new_player.set_name(String.num_int64(player))
		player_root.add_child(new_player)
		new_player.set_multiplayer_authority(player)
		new_player.level_tiles = level.get_node("LevelTiles")
		new_player.player_tiles = level.get_node("PlayerTiles")
		new_player.camera = camera
		if new_player.is_multiplayer_authority():
			local_player = new_player
			camera.player = local_player
			camera.reposition(spawnpoints[team].get_point())
			new_player.crosshair = crosshair
			new_player.ui = ui
		new_player.position = spawnpoints[team].get_point()
		new_player.modulate = new_player.COLORS[team]
	
	



