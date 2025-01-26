class_name Bubble extends Node3D
var gridPos: Vector3i = Vector3.ZERO
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var label: Label3D = $Label3D
var victim: Character
var hasVictim = false
@export var liveTime = 3

func set_spawn(pos: Vector3i, grid: Map) -> void:
	gridPos = pos
	global_position = grid.map_to_global(gridPos)
	label.text = ""

func pop(grid: Map) -> void:
	if(hasVictim):
		victim.bubbleVictim = false
		victim.fall(grid)
	queue_free()
	
func push(from: Vector3i, grid: Map, bubbles: Array[Bubble]) -> bool:
	var dir := gridPos - from
	var moveCoords := gridPos + dir
	
	var obstacle := grid.get_cell_item(moveCoords)
	
	match obstacle:
		-1: # no collision
			pass
		0: # collision with block stops movement
			return false
		1: # collision with ramp moves you up
			moveCoords += Vector3i.UP
		_: # collision with something we don't know how to handle
			assert(obstacle == -1)
			
	for bubble in bubbles:
		if is_instance_valid(bubble) and bubble != self and bubble.gridPos == moveCoords:
			return false
	
	gridPos = moveCoords
	global_position = grid.map_to_global(gridPos)
	
	if hasVictim:
		victim.setPos(gridPos, grid)
	
	return true
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	var ch := body.get_parent() as Character
	if !ch :
		return
	if(!hasVictim):
		hasVictim = true
		victim = ch
		victim.bubbleVictim = true
		victim.model.stop()
		animation.play("bob")
		label.text = str(liveTime)
	

func liveSpindown(grid: Map) -> void:
	liveTime -= 1
	label.text = str(liveTime)
	if(liveTime <= 0):
		pop(grid)
