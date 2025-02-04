extends Node3D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("rot_cam_clockwise") and self.rotation_degrees.y < 25+30:
		self.rotate_y(0.01)
	if Input.is_action_pressed("rot_cam_counterclockwise") and self.rotation_degrees.y > -25+30:
		self.rotate_y(-0.01)
	if Input.is_action_pressed("cam_zoom_in"):
		$Camera3D.size += 0.01
	if Input.is_action_pressed("cam_zoom_out"):
		$Camera3D.size -= 0.01
	if Input.is_action_just_pressed("reset_camera"):
		self.rotation = Vector3(-45,45,0)
		$Camera3D.size = 7.7
