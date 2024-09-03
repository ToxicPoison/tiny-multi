extends Node2D

@onready var collision = $"../../CrosshairCollision"
@onready var camera = $"../../Camera2D"

func _physics_process(delta):
	collision.global_position = global_position + camera.global_position - get_viewport_rect().size/2.0
	
func is_colliding() -> bool:
	if collision.get_overlapping_bodies():
		return true
	return false
