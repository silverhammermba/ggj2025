extends AudioStreamPlayer2D



func play():
	pitch_scale = randf_range(0.8,1.2)
	$".".play()
