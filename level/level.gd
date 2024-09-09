extends Node2D

const TILE_SIZE := 16
const WATER_DEPTH := 64.0
const VARIATIONS := 4

@onready var player_tiles := $PlayerTiles

func tile_position(point : Vector2) -> Vector2i:
	var pos_rounded = point.round() / TILE_SIZE
	if pos_rounded.x < 0: pos_rounded.x -= 1
	if pos_rounded.y < 0: pos_rounded.y -= 1
	return pos_rounded
	
func _ready():
	SignalBus.connect("bullet_exploded", _on_explosion)
	
func _on_explosion(pos : Vector2):
	var coords:Array[Vector2i] = player_tiles.get_surrounding_cells(tile_position(pos))
	coords.append(tile_position(pos))
	for coord in coords:
		damage_tile(coord)

func damage_tile(coord : Vector2i):
	var atlas_coord = player_tiles.get_cell_atlas_coords(3, coord)
	var new_atlas_coord = atlas_coord + Vector2i(VARIATIONS*2*3, 0)
	if new_atlas_coord.x <= VARIATIONS * 3 * 3:
		player_tiles.set_cell(3, coord, 1, new_atlas_coord)
		return
	player_tiles.erase_cell(0, coord)
	player_tiles.erase_cell(2, coord)
	player_tiles.erase_cell(3, coord)
	player_tiles.erase_cell(1, coord + Vector2i(0, int(WATER_DEPTH) / TILE_SIZE))
	return

func get_spawn(team : int) -> Vector2:
	for c in get_tree().get_nodes_in_group("spawn"):
		if c.team == team:
			return c.get_point()
	return Vector2.ZERO


func build(location : Vector2i, team : int, buildable : int, random : int) -> void:
	var atlas_pos = Vector2i(team, buildable)
	player_tiles.set_cell(0, location, 0, atlas_pos)
	var visual_atlas_pos = Vector2i((random % VARIATIONS) * 3, (buildable + team * 4) * 3)
	player_tiles.set_cell(3, location, 1, visual_atlas_pos)
	player_tiles.set_cell(2, location, 1, visual_atlas_pos + Vector2i(VARIATIONS * 3, 0))
	player_tiles.set_cell(1, location + Vector2i(0, int(WATER_DEPTH) / TILE_SIZE), 1, visual_atlas_pos + Vector2i(VARIATIONS * 3, 0))
	#x coor = (random%variations) * 3
