extends Node2D

func explode_super():
	$AnimationPlayer.play("explosion_super")

func explosion_complete():
	queue_free()
