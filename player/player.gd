extends CharacterBody2D

const SPEED : float = 100.0
const STEP_SIZE := 20.0
const WALK_FRAMES := 4
const FRICTION_FACTOR : float = 0.5
const TILE_SIZE := 16
const COLORS = [Color.LIGHT_CORAL, Color.ROYAL_BLUE]

var crosshair : Object
var camera : Camera2D
var ui : Object
var team : int = 0

var num_buildables := 2
var buildable : int = 0
var build_cooldown : float = 0.0
const BUILD_RATE := 0.15 #smaller = faster

var shoot_cooldown : float = 0.0
const SHOOT_RATE := 0.25

var player_tiles : TileMap ##if get_cell_source_id < 0: then fall
var level_tiles : TileMap
var travel : float = 0.0
var prev_pos := Vector2.ZERO
var target := Vector2.ZERO
var global_target := Vector2.ZERO

@onready var sprite = $Body

func check_for_tile(location : Vector2i, tilemap : int) -> bool:
	match tilemap:
		0:
			return level_tiles.get_cell_source_id(0, location) > -1
		1:
			return player_tiles.get_cell_source_id(0, location) > -1
		_:
			return false

func tile_position(point : Vector2) -> Vector2i:
	var pos_rounded = point.round() / TILE_SIZE
	if pos_rounded.x < 0: pos_rounded.x -= 1
	if pos_rounded.y < 0: pos_rounded.y -= 1
	return pos_rounded

@rpc("any_peer", "call_local", "reliable")
func shoot(direction : Vector2) -> void:
	print("bang")
	
func build() -> void:
	if global_target.distance_squared_to(position) > 6400.0: return
	if buildable == 0 and crosshair.is_colliding(): return
	var location := tile_position(global_target)
	if buildable == 1 and (check_for_tile(location, 0) or check_for_tile(location, 1)): return
	place_tile.rpc(location, buildable)
	
@rpc("any_peer", "call_local", "unreliable")
func place_tile(location : Vector2i, buildable) -> void:
	var atlas_pos = Vector2i(team, buildable)
	var location_offset = Vector2i.ZERO
	if buildable >= 1:
		atlas_pos += Vector2i(0, 1)
		location_offset = Vector2i(0,0)
	player_tiles.set_cell(0, location + location_offset, 0, atlas_pos)

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("changeItemUp"):
		buildable = (buildable + 1) % num_buildables
		ui.change_selection(buildable)
	if event.is_action_pressed("changeItemDown"):
		buildable = (absi(buildable - 1)) % num_buildables
		print(buildable)
		ui.change_selection(buildable)


func _physics_process(delta):
	if is_multiplayer_authority():
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = velocity.lerp(direction * SPEED, FRICTION_FACTOR)

		# player fall into water if check_tile yields false for both (and, later, if ysort >= 0)
			
		if direction:
			sprite.set_flip_h(direction.x < 0.0)
			travel = fmod(travel + velocity.length() * delta, STEP_SIZE)
			sprite.frame = floori((travel/STEP_SIZE) * WALK_FRAMES)
		else:
			sprite.frame = 0
			
		target = get_viewport().get_mouse_position() - get_viewport_rect().size/2.0
		global_target = target + camera.position
		crosshair.position = get_viewport().get_mouse_position()
			
		build_cooldown = maxf(build_cooldown - delta, 0.0)
		if build_cooldown < 0.1 and Input.is_action_pressed("build"):
			build()
			build_cooldown = BUILD_RATE
		
		shoot_cooldown = maxf(shoot_cooldown - delta, 0.0)
		if shoot_cooldown < 0.1 and Input.is_action_pressed("shoot"):
			shoot.rpc(global_target)
			shoot_cooldown = SHOOT_RATE
		
		move_and_slide()
	
	
	####################################### OTHER PEERS:
	else:
		var delta_position = position - prev_pos
		var distance = delta_position.length()
		if delta_position.length() > 0.1:
			sprite.set_flip_h(delta_position.x < 0.0)
			travel = fmod(travel + distance * delta * 40.0, STEP_SIZE)
			sprite.frame = floori((travel/STEP_SIZE) * WALK_FRAMES)
		else:
			sprite.frame = 0
		prev_pos = position
		
	

