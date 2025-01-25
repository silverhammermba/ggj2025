class_name Bubble extends Node3D
var gridPos: Vector3i = Vector3.ZERO
	
func set_spawn(pos: Vector3i, grid: Map) -> void:
	gridPos = pos
	global_position = grid.map_to_global(gridPos)
