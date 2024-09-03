
extends Node2D

@export_enum("Red", "Blue", "Green", "Purple") var team : int = 0

@export var extents := Vector2(32,32)

func get_point() -> Vector2:
	return position + Vector2(randf(), randf()) * extents
