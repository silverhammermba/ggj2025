class_name Bubble extends Node3D
var gridPos: Vector3i = Vector3.ZERO
@onready var animation: AnimationPlayer = $AnimationPlayer

var victim: Character
var hasVictim = false

func set_spawn(pos: Vector3i, grid: Map) -> void:
	gridPos = pos
	global_position = grid.map_to_global(gridPos)

func pop(grid: Map) -> void:
	if(hasVictim):
		victim.bubbleVictim = false
		victim.fall(grid)
	queue_free()
	
func push(from: Vector3i, grid: Map) -> void:
	var dir := gridPos - from
	var moveCoords := gridPos + dir
	
	var obstacle := grid.get_cell_item(moveCoords)
	
	match obstacle:
		-1: # no collision
			pass
		0: # collision with block stops movement
			return
		1: # collision with ramp moves you up
			moveCoords += Vector3i.UP
		_: # collision with something we don't know how to handle
			assert(obstacle == -1)
	
	gridPos = moveCoords
	global_position = grid.map_to_global(gridPos)
	
	if hasVictim:
		victim.setPos(gridPos, grid)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	var ch := body.get_parent() as Character
	if !ch:
		return
	hasVictim = true
	victim = ch
	victim.bubbleVictim = true
	victim.animation.stop()
	animation.play("bob")
