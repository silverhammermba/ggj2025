class_name Map extends GridMap

func global_to_map(global: Vector3) -> Vector3i:
	return local_to_map(to_local(global))

func map_to_global(map: Vector3i) -> Vector3:
	return to_global(map_to_local(map))

func global_to_open(global: Vector3) -> Vector3i:
	var pos := global_to_map(global)
	# if inside a block, get the open space on top
	while get_cell_item(pos) != -1:
		pos.y += 1
	return pos
