extends StaticBody2D
class_name Tower

@export_enum("Red", "Blue", "Green", "Purple") var team : int = 0
const COLORS = [Color.ORANGE_RED, Color.ROYAL_BLUE]
const MAX_HEALTH := 120
@onready var health := MAX_HEALTH

func _ready():
	modulate = COLORS[team]

func set_health(new_health : float) -> void:
	health = new_health
	$Sprite.frame = 3 - health / (MAX_HEALTH / 3)
	
func damage():
	var new_health = health - 10
	if new_health < 1:
		print("I am going to die.")
	else:
		set_health(new_health)
