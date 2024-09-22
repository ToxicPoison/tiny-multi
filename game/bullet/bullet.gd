extends AnimatableBody2D

const EXPLOSION_SCENE := preload("res://game/bullet/explosion.tscn")
var direction := Vector2.ZERO
var sender : Node2D
var p_velocity := Vector2.ZERO # player's velocity when they fired the bullet
var velocity := Vector2.ZERO
var done := false
const SPEED := 400.0
const EXPLODE_TIME := 0.5
const TILE_SIZE := 16
@onready var time := EXPLODE_TIME

func tile_position(point : Vector2) -> Vector2i:
	var pos_rounded = point.round() / TILE_SIZE
	if pos_rounded.x < 0: pos_rounded.x -= 1
	if pos_rounded.y < 0: pos_rounded.y -= 1
	return pos_rounded
	

func _ready():
	add_collision_exception_with(sender)

func _physics_process(delta):
	if done: return
	velocity = (direction * SPEED + p_velocity) * delta
	var bonk := move_and_collide(velocity)
	if not is_multiplayer_authority(): return
	
	if bonk:
		var team := -1
		var player_hit := false
		if bonk.get_collider() is Tower:
			team = bonk.get_collider().team
		if bonk.get_collider() is CharacterBody2D:
			player_hit = true
		explode.rpc(global_position + velocity, team, player_hit)
		die()
	time -= delta
	if time < 0.0:
		explode.rpc(global_position + velocity, -1, false)
		die()
		
@rpc("any_peer", "call_local", "reliable")
func explode(posn : Vector2, team : int, player_hit : bool) -> void:
	done = true
	var explosion_effect = EXPLOSION_SCENE.instantiate()
	explosion_effect.global_position = global_position
	get_parent().add_child(explosion_effect)
	if player_hit: explosion_effect.explode_super()
	SignalBus.bullet_exploded.emit(posn)
	if team > -1:
		for t in get_tree().get_nodes_in_group("tower"):
			if t.team == team:
				t.damage()
	
func die():
	free_remote.rpc()
	await get_tree().create_timer(0.1).timeout
	queue_free()
	
@rpc("any_peer", "call_remote", "reliable")
func free_remote():
	queue_free()
