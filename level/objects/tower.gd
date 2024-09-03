extends StaticBody2D

@export_enum("Red", "Blue", "Green", "Purple") var team : int = 0
const COLORS = [Color.LIGHT_CORAL, Color.ROYAL_BLUE]

func _ready():
	modulate = COLORS[team]
