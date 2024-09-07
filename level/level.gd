extends Node2D

const TILE_SIZE := 16
const WATER_DEPTH := 128.0

func tile_position(point : Vector2) -> Vector2i:
	var pos_rounded = point.round() / TILE_SIZE
	if pos_rounded.x < 0: pos_rounded.x -= 1
	if pos_rounded.y < 0: pos_rounded.y -= 1
	return pos_rounded
	
func _ready():
	SignalBus.connect("bullet_exploded", _on_explosion)
	
func _on_explosion(pos : Vector2):
	var coords:Array[Vector2i] = $PlayerTiles.get_surrounding_cells(tile_position(pos))
	coords.append(tile_position(pos))
	for coord in coords:
		$PlayerTiles.erase_cell(0, coord)

func get_spawn(team : int) -> Vector2:
	for c in get_tree().get_nodes_in_group("spawn"):
		if c.team == team:
			return c.get_point()
	return Vector2.ZERO
