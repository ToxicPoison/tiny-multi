extends AudioStreamPlayer2D

@export var min_pitch : float = 0.9
@export var max_pitch : float = 1.1

func play_randomized():
	pitch_scale = randf_range(min_pitch, max_pitch)
	play()
