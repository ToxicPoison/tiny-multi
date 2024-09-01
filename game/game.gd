extends Node2D

const CAMERA_SPEED := 70.0
const CAMERA_WIGGLE_ROOM := 1000.0

@onready var crosshair = $CanvasLayer/Control/Crosshair
@onready var camera = $Camera2D
@onready var player = $Player

var camera_target_position := Vector2.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	await get_tree().create_timer(1).timeout
	$Player.tilemap = $PlatformBasic
	print($Player.tilemap)
	
func _input(event):
	if event is InputEventMouseMotion:
		crosshair.position = event.position

func _process(delta):
	if camera and player and camera_target_position.distance_squared_to(player.global_position) > CAMERA_WIGGLE_ROOM:
		camera_target_position = camera_target_position.move_toward(player.global_position, CAMERA_SPEED * delta)
		camera.global_position = camera_target_position.round()
