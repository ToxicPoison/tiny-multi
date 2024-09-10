extends Node2D

var player_scene := preload("res://player/player.tscn")
var player_root : Object
var level_scene : PackedScene = preload("res://level/platform_basic.tscn")
var level
var spawnpoints = [null, null]
var team_names = ["RED", "BLUE"]
const COLORS = [Color.ORANGE_RED, Color.ROYAL_BLUE]
var score = [5, 5]

var pause_menu : Object = null

@onready var crosshair = $UILayer/Crosshair
@onready var camera = $Camera2D
@onready var ui = $UILayer
@onready var victory_text = $UILayer/UI/VictoryText

var local_player : Object

func _ready():
	ServerSingleton.player_loaded.rpc_id(1)
	if ServerSingleton.is_multiplayer_authority(): 
		ServerSingleton.connect("players_loaded_in_new_scene", start_game)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	

func _input(event):
	if event.is_action_pressed("pause"):
		if not pause_menu:
			pause_menu = preload("res://menus/pause_menu.tscn").instantiate()
			ui.add_child(pause_menu)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			pause_menu.queue_free()
			pause_menu = null
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
			new_player.tile_outline = $TileOutline
		new_player.position = spawnpoints[team].get_point()
		new_player.modulate = new_player.COLORS[team]
	
@rpc("authority", "call_local", "reliable")
func dock_point(team):
	for t in get_tree().get_nodes_in_group("tower"):
		t.active = false
	
	score[team] -= 1
	if score[team] <= 0:
		victory_text.get_child(0).text = team_names[1 - team] + " HAS WON"
		victory_text.get_child(0).modulate = COLORS[1 - team]
		victory_text.get_child(1).text = "Sucks to be YOU, " + team_names[team] + "!"
		victory_text.get_child(1).modulate = COLORS[team]
		victory_text.set_visible(true)
		await get_tree().create_timer(5.0).timeout
		ServerSingleton.load_scene("res://lobby/lobby.tscn")
		return
	
	victory_text.get_child(0).text = team_names[team] + " lost a point!"
	victory_text.get_child(0).modulate = COLORS[team]
	victory_text.get_child(1).text = team_names[0] + " " + String.num_int64(score[0]) + " : " + team_names[1] + " " + String.num_int64(score[1])
	victory_text.set_visible(true)
	
	await get_tree().create_timer(3.0).timeout 
	for p in get_tree().get_nodes_in_group("player"):
		p.respawn()
	for t in get_tree().get_nodes_in_group("tower"):
		t.set_health(t.MAX_HEALTH)
		t.active = true
	victory_text.set_visible(false)


