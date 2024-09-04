extends Area2D

var direction := Vector2.ZERO
var sender : Node2D
var p_velocity := Vector2.ZERO # player's velocity when they fired the bullet
const SPEED := 500.0
const EXPLODE_TIME := 0.8
const TILE_SIZE := 16
@onready var time := EXPLODE_TIME

func tile_position(point : Vector2) -> Vector2i:
	var pos_rounded = point.round() / TILE_SIZE
	if pos_rounded.x < 0: pos_rounded.x -= 1
	if pos_rounded.y < 0: pos_rounded.y -= 1
	return pos_rounded

func _ready():
	if is_multiplayer_authority():
		connect("body_entered", on_body_entered)

func _physics_process(delta):
	global_position += (direction * SPEED + p_velocity) * delta
	if not is_multiplayer_authority(): return
	time -= delta
	if time < 0.0:
		explode()
		
func explode():
	print("bye guys")
	queue_free()
	#knock players away
	#damage the tower
	#break surrounding tiles
	
func on_body_entered(body):
	if is_multiplayer_authority() and body != sender:
		explode()
