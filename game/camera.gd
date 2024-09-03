extends Camera2D

enum state {UNCONTROLLED, FOLLOW_PLAYER}

const CAMERA_SPEED := 70.0
const CAMERA_WIGGLE_ROOM := 1000.0

var camera_target_position := Vector2.ZERO
var player : Object = null
var mode := state.FOLLOW_PLAYER

func _process(delta):
	match mode:
		state.UNCONTROLLED:
			pass
		state.FOLLOW_PLAYER:
			if player and camera_target_position.distance_squared_to(player.global_position) > CAMERA_WIGGLE_ROOM:
				camera_target_position = camera_target_position.move_toward(player.global_position, CAMERA_SPEED * delta)
				global_position = camera_target_position.round()
				
func reposition(point : Vector2):
	camera_target_position = point
	position = point
	
