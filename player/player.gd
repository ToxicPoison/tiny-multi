extends CharacterBody2D

const SPEED : float = 100.0
const STEP_SIZE := 20.0
const WALK_FRAMES := 4
const FRICTION_FACTOR : float = 0.5
const AIR_FRICTION_FACTOR : float = 0.05
const TILE_SIZE := 16
const COLORS = [Color.ORANGE_RED, Color.ROYAL_BLUE]
const BULLET_SCENE = preload("res://game/bullet/bullet.tscn")


var crosshair : Object
var camera : Camera2D
var tile_outline : Object
var ui : Object
var team : int = 0

var num_buildables := 2
var buildable : int = 0
var build_cooldown : float = 0.0
const BUILD_RATE := 0.15 #smaller = faster
const BUILD_RANGE := 6 #in tiles 

var shoot_cooldown : float = 0.0
const SHOOT_RATE := 0.5
const LOWEST_SHOOT_HEIGHT := 8.0

var player_tiles : TileMap ##if get_cell_source_id < 0: then fall
var level_tiles : TileMap

var z_speed := 0.0
var z_position := 0.0
var on_ground := true
const JUMP_SPEED := 150.0
const GRAVITY := 490.0
var travel : float = 0.0
var prev_pos := Vector2.ZERO
var target := Vector2.ZERO
var global_target := Vector2.ZERO

@onready var sprite = $Body
@onready var footprint = $FootprintRef
var footprint_vectors = [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,-1), Vector2i(-1,1)]

func _ready():
	SignalBus.connect("bullet_exploded", _on_explosion)


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
func shoot(direction : Vector2, p_velocity : Vector2, b_name : String) -> void:
	$ShootSound.play_randomized()
	var new_bullet = BULLET_SCENE.instantiate()
	new_bullet.set_multiplayer_authority(get_multiplayer_authority())
	new_bullet.set("sender", self)
	new_bullet.set("name", b_name)
	get_parent().add_child(new_bullet)
	new_bullet.position = position
	new_bullet.direction = direction
	new_bullet.p_velocity = p_velocity
	new_bullet.modulate = modulate
	
func check_for_neighbor_tile(coord : Vector2i) -> bool:
	for t in player_tiles.get_surrounding_cells(coord):
		if check_for_tile(t, 0) or check_for_tile(t, 1):
			return true
	return false
	
func build() -> void:
	if global_target.distance_to(position) > float(BUILD_RANGE * TILE_SIZE): return
	if buildable == 0 and crosshair.is_colliding(): return
	var location := tile_position(global_target)
	if player_tiles.get_cell_atlas_coords(0, location).y == 0: return
	#if not check_for_neighbor_tile(location): return
	if buildable == 1 and (check_for_tile(location, 0) or check_for_tile(location, 1)): return
	place_tile.rpc(location, buildable, randi())
	
	
	
@rpc("any_peer", "call_local", "unreliable")
func place_tile(location : Vector2i, buildable : int, random : int) -> void:
	$BuildSound.play_randomized()
	get_parent().build(location, team, buildable, random)


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("jump") and on_ground:
		z_speed = -JUMP_SPEED
		on_ground = false
	if event.is_action_pressed("changeItemUp"):
		buildable = (buildable + 1) % num_buildables
		ui.change_selection(buildable)
	if event.is_action_pressed("changeItemDown"):
		buildable = (absi(buildable - 1)) % num_buildables
		print(buildable)
		ui.change_selection(buildable)


func knock_back(k_velocity : Vector3):
	if not is_multiplayer_authority(): return
	velocity = Vector2(k_velocity.x, k_velocity.y)
	if z_speed < 1.0:
		z_speed = k_velocity.z
		on_ground = false


func _on_explosion(pos : Vector2):
	if not is_multiplayer_authority(): return
	var range := 40.0
	if pos.distance_to(position) > range: return
	var strength := 200.0
	var knock_vector := (position - pos).normalized() * strength
	var z_factor := 1.0
	if absf(z_position) > 0.1:
		z_factor = minf(1.0 / (absf(z_position) / 16.0), 1.0)
		
	knock_back(Vector3(knock_vector.x, knock_vector.y, -strength * 0.5) * z_factor)


func respawn():
	if not is_multiplayer_authority(): return
	position = get_parent().get_spawn(team)
	velocity = Vector2.ZERO
	on_ground = true
	z_position = 0.0
	z_speed = 0.0
	camera.reposition(position)


func _physics_process(delta):
	var on_tile := false
	for vec in footprint_vectors:
		var p = footprint.position * Vector2(vec) + position
		if check_for_tile(tile_position(p), 0) or check_for_tile(tile_position(p), 1):
			on_tile = true
			break
	$Shadow.set_visible(on_tile and z_position < 0.1)
	
	####################################### LOCAL:
	if is_multiplayer_authority():
		if not on_tile: on_ground = false
		if not on_ground:
			z_speed += GRAVITY * delta
			var last_z := z_position
			z_position += z_speed * delta
			if z_position > 0.0 and last_z < 0.0 and on_tile:
				on_ground = true
				z_position = 0.0
				z_speed = 0.0
			if z_position > get_parent().WATER_DEPTH:
				respawn()
		$Body.offset = Vector2(0.0, z_position - 8.0)
		
		var direction = Input.get_vector("left", "right", "up", "down")
		if on_ground: velocity = velocity.lerp(direction * SPEED, FRICTION_FACTOR)
		else: velocity = velocity.lerp(direction * SPEED, AIR_FRICTION_FACTOR)
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
		tile_outline.position = Vector2(tile_position(global_target) * TILE_SIZE) + Vector2(8.0,8.0)
		tile_outline.set_visible(global_target.distance_to(position) < float(BUILD_RANGE * TILE_SIZE))
			
		build_cooldown = maxf(build_cooldown - delta, 0.0)
		if build_cooldown < 0.1 and Input.is_action_pressed("build"):
			build()
			build_cooldown = BUILD_RATE
		
		shoot_cooldown = maxf(shoot_cooldown - delta, 0.0)
		if shoot_cooldown < 0.1 and Input.is_action_pressed("shoot") and z_position < LOWEST_SHOOT_HEIGHT:
			shoot.rpc((global_target - position).normalized(), velocity, "bullet" + String.num_int64(get_parent().get_child_count() + Time.get_ticks_msec()))
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
		
	

