class_name Bubble extends Node3D
var gridPos: Vector3i = Vector3.ZERO
	
func set_spawn(pos: Vector3i, grid: Map) -> void:
	# if would spawn inside a block, spawn on top of it
	while grid.get_cell_item(pos) != -1:
		pos.y += 1
	gridPos = pos
	global_position = grid.map_to_global(gridPos)
