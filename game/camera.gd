extends Camera2D

enum state {UNCONTROLLED, FOLLOW_PLAYER}

const CAMERA_SPEED := 80.0
const CAMERA_WIGGLE_ROOM := 1000.0

var camera_target_position := Vector2.ZERO
var player : Object = null
var mode := state.FOLLOW_PLAYER

func _process(delta):
	match mode:
		state.UNCONTROLLED:
			pass
		state.FOLLOW_PLAYER:
			if player:
				camera_target_position = player.position
				global_position = camera_target_position.round()
				
func reposition(point : Vector2):
	camera_target_position = point
	#position = point
	
