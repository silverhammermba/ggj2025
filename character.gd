class_name Character extends Node3D

@onready var animation: AnimationPlayer = $CharacterBody3D/AnimationPlayer
var gridPos: Vector3i = Vector3.ZERO

func deselect() -> void:
	animation.stop()

func select() -> void:
	animation.play("bob")

func move(moveCoords: Vector3i, grid: GridMap) -> void:
	#collision with ramp moves you up
	if(grid.get_cell_item(moveCoords)  == 1):
		moveCoords += Vector3i.UP
	
	#collision with block stops movement
	if(grid.get_cell_item(moveCoords)  == 0):
		return
		
	#if current grid cell is empty (you are in the air) fall until you hit a floor
	for n in range(0,10):
		if(grid.get_cell_item(moveCoords) != -1):
			moveCoords += Vector3i.UP
			break
		elif (n == 9):
			queue_free()
		moveCoords += Vector3i.DOWN
		
	gridPos = moveCoords
	var newPos := grid.map_to_local(gridPos)
	global_position = grid.to_global(newPos)
