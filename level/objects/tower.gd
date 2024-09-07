extends StaticBody2D
class_name Tower

@export_enum("Red", "Blue", "Green", "Purple") var team : int = 0
const COLORS = [Color.ORANGE_RED, Color.ROYAL_BLUE]
const MAX_HEALTH := 120
@onready var health := MAX_HEALTH
var active := true
var game : Object

func _ready():
	modulate = COLORS[team]
	game = get_parent().get_parent()

func set_health(new_health : float) -> void:
	health = new_health
	$Sprite.frame = 3 - health / (MAX_HEALTH / 3)
	
func damage():
	if not active: return
	var new_health = health - 10
	if new_health < 20:
		if ServerSingleton.multiplayer.multiplayer_peer.get_unique_id() == 1:
			game.dock_point.rpc(team)
	else:
		set_health(new_health)
