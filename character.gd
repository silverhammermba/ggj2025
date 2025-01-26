class_name Character extends Node3D

@onready var animation: AnimationPlayer = $CharacterBody3D/AnimationPlayer
@onready var sprite: Sprite3D = $CharacterBody3D/Sprite3D
var gridPos := Vector3i.ZERO
var bubbleVictim = false

@export var classBlower := false
@export var classPopper := false
@export var classPusher := false

@export var team := 0
@export var max_actions := 1
@export var max_moves := 3
@export var max_timeout := 3
var actions := 0
var moves := 0
var timeout := 0

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

# reset character, return true if they need to respawn
func new_turn(currentTeam: int) -> bool:
	if team != currentTeam:
		actions = 0
		moves = 0
		return false
	var respawn := false
	if timeout > 0:
		timeout -= 1
		respawn = timeout <= 0
	actions = max_actions
	moves = max_moves
	return respawn

func has_actions(currentTeam: int) -> bool:
	if team != currentTeam:
		return false
	if timeout > 0:
		return false
	return actions > 0 or moves > 0

func status() -> String:
	var klass := "Blower"
	if classPopper:
		klass = "Popper"
	elif classPusher:
		klass = "Pusher"
	var charState := "%d move, %d action" % [moves, actions]
	if timeout > 0:
		charState = "RESPAWNING (%d)" % timeout
	elif bubbleVictim:
		charState = "BUBBLED!"
	return "%s: %s" % [klass, charState]

func grid_dist(pos: Vector3i) -> int:
	return absi(pos.x - gridPos.x) + absi(pos.y - gridPos.y) + absi(pos.z - gridPos.z)

func setPos(pos: Vector3i, grid: Map) -> void:
	gridPos = pos
	global_position = grid.map_to_global(gridPos)

func fall(grid: Map) -> void:
	var testPos := gridPos
	# fall until you hit a floor
	var max_iter: = 10
	for n in range(0, max_iter):
		testPos += Vector3i.DOWN
		if grid.get_cell_item(testPos) != -1:
			# found floor, move back up
			testPos += Vector3i.UP
			break
		elif n == max_iter - 1:
			# fell too far (or fell off map)
			timeout = max_timeout
			setPos(Vector3i(-50, 0, -50), grid)
			return
	setPos(testPos, grid)

func move(moveCoords: Vector3i, grid: Map) -> void:
	if moves <= 0 or bubbleVictim or timeout > 0:
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
	
	setPos(moveCoords, grid)
	fall(grid)
