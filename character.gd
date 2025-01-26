class_name Character extends Node3D

@onready var generalist: CharacterModel = $CharacterBody3D/Generalist
@onready var blower: CharacterModel = $CharacterBody3D/Blower
@onready var popper: CharacterModel = $CharacterBody3D/Popper
@onready var pusher: CharacterModel = $CharacterBody3D/Pusher
var model: CharacterModel
var gridPos := Vector3i.ZERO
var bubbleVictim = false

@export var PopperImg : Texture2D
@export var PusherImg : Texture2D
@export var BlowerImg : Texture2D

@export var classBlower := false
@export var classPopper := false
@export var classPusher := false

@export var team := 0
@export var max_actions := 1
@export var max_moves := 3
@export var max_timeout := 3
@export var fallPos := Vector3i(-50, 0, -50)
var actions := 0
var moves := 0
var timeout := 0

@export var team0Overlay: StandardMaterial3D
@export var team1Overlay: StandardMaterial3D

func _ready() -> void:
	model = generalist
	generalist.visible = false
	if classBlower:
		model = blower
	elif classPopper:
		model = popper
	elif classPusher:
		model = pusher
	model.visible = true
	model.idle()
	var overlay := team0Overlay
	match team:
		0:
			pass
		1:
			model.rotate_y(PI / 2)
			overlay = team1Overlay
	var meshes := model.find_children("*", "MeshInstance3D")
	for mesh in meshes:
		mesh.material_overlay = overlay

func deselect() -> void:
	# TODO: if your last action has animation, this cancels it. somehow wait for it to finish
	model.idle()

func select() -> void:
	model.walk()

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

func name() -> String:
	var klass := "Blower"
	if classPopper:
		klass = "Popper"
	elif classPusher:
		klass = "Pusher"
	return klass

func picture() -> Texture2D:
	if classPopper:
		return PopperImg
	elif classPusher:
		return PusherImg
	return BlowerImg
	
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
			setPos(fallPos, grid)
			return
	setPos(testPos, grid)

func move(moveCoords: Vector3i, grid: Map, characters: Array[Character]) -> void:
	if moves <= 0 or bubbleVictim or timeout > 0:
		return
	
	var currPos = gridPos
	
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

	var sameSpace := false
	for ch in characters:
		if ch != self and ch.timeout <= 0 and ch.gridPos == gridPos:
			sameSpace = true
			break
	
	if sameSpace:
		setPos(currPos, grid)
		return
	
	model.walk()
	moves -= 1

func push(from: Vector3i, grid: Map, characters: Array[Character]) -> bool:
	var currPos := gridPos
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
			
	setPos(moveCoords, grid)
	fall(grid)
	
	var sameSpace := false
	for ch in characters:
		if ch != self and ch.timeout <= 0 and ch.gridPos == gridPos:
			sameSpace = true
			break
	
	if sameSpace:
		setPos(currPos, grid)
		return false

	return true
