class_name Character extends Node3D

@onready var animation: AnimationPlayer = $CharacterBody3D/AnimationPlayer
@onready var sprite: Sprite3D = $CharacterBody3D/Sprite3D
var gridPos: Vector3i = Vector3.ZERO
var bubbleVictim = false

@export var classBlower := false
@export var classPopper := false
@export var classPusher := false

@export var team := 0
@export var max_actions := 1
@export var max_moves := 3
var actions := 0
var moves := 0

func _ready() -> void:
	match team:
		0:
			sprite.modulate = Color.GREEN
		1:
			sprite.modulate = Color.BLUE

func deselect() -> void:
	animation.stop()

func select() -> void:
	animation.play("bob")
	
func new_turn(currentTeam: int) -> void:
	if team != currentTeam:
		actions = 0
		moves = 0
		return
	actions = max_actions
	moves = max_moves
	
func has_actions(currentTeam: int) -> bool:
	if team != currentTeam:
		return false
	return actions > 0 or moves > 0

func move(moveCoords: Vector3i, grid: Map) -> void:
	if moves <= 0:
		return
	
	moves -= 1
	
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
		
	# fall until you hit a floor
	for n in range(0,10):
		moveCoords += Vector3i.DOWN
		if grid.get_cell_item(moveCoords) != -1:
			# found floor, move back up
			moveCoords += Vector3i.UP
			break
		elif n == 9:
			queue_free()
	
	if(!bubbleVictim):
		gridPos = moveCoords
		global_position = grid.map_to_global(gridPos)
	
