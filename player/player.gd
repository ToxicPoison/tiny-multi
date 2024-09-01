extends CharacterBody2D

const SPEED : float = 100.0
const STEP_SIZE := 20.0
const WALK_FRAMES := 4
const FRICTION_FACTOR : float = 0.5
const tile_size := 16

var tilemap : TileMap ##if get_cell_source_id < 0: then fall
var travel : float = 0.0

@onready var sprite = $Body


#add rpc
@rpc("any_peer", "call_local", "reliable")
func shoot(direction : Vector2):
	print("bang")
	
	
@rpc("any_peer", "call_local", "reliable")
func build(location : Vector2):
	print("plop")


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event.is_action_pressed("shoot"):
		shoot.rpc(Vector2.ZERO) #add rpc
	if event.is_action_pressed("build"):
		build.rpc(Vector2.ZERO) #add rpc


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp(direction * SPEED, FRICTION_FACTOR)

	if tilemap:
		var pos_rounded = position.round() / tile_size
		if pos_rounded.x < 0: pos_rounded.x -= 1
		if pos_rounded.y < 0: pos_rounded.y -= 1
		var id := tilemap.get_cell_source_id(0, Vector2i(pos_rounded))
		$Label.text = String.num_int64(id)
		
	if direction:
		sprite.set_flip_h(direction.x < 0)
		travel = fmod(travel + velocity.length() * delta, STEP_SIZE)
		sprite.frame = floori((travel/STEP_SIZE) * WALK_FRAMES)
	else:
		sprite.frame = 0

	move_and_slide()
	
	
