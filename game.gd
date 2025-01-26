class_name Game extends Node3D

@onready var gridMap: Map = $map
@onready var camera: Camera3D = $"camera pivot/Camera3D"

@export var RAY_CAST_LENGTH := 1000
@export var bubbleScene : PackedScene
@export var bubbleRange = 3
@export var popRange = 2
@export var pushRange = 1
@export var pushDistance = 3

var characters: Array[Character] = []
var bubbles: Array[Bubble] = []
var selection := -1
var newRayCast := false
var rayOrigin := Vector3.ZERO
var rayEnd := Vector3.ZERO
var currentTeam := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chars = get_tree().get_nodes_in_group("character")
	
	for node in chars:
		var ch: Character = node
		characters.append(ch)
		# give each character a free "move" to snap to the grid
		ch.moves = 1
		ch.move(gridMap.global_to_map(ch.position), gridMap)
		ch.new_turn(currentTeam)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var prev_selection := selection
	
	var has_actions := false
	for ch in characters:
		if ch.has_actions(currentTeam):
			has_actions = true
			break
	if !has_actions or Input.is_action_just_pressed("end_turn"):
		new_turn()
		# check again if new team has actions
		has_actions = false
		for ch in characters:
			if ch.has_actions(currentTeam):
				has_actions = true
				break
	
	if !has_actions:
		# TODO: game over? this side has no playable characters
		return
	
	if Input.is_action_just_pressed("prev char"):
		while true:
			if selection >= 0:
				selection -= 1
				if selection < 0:
					selection = characters.size() - 1
			else:
				selection = characters.size() - 1
			if characters[selection].has_actions(currentTeam):
				break
	elif Input.is_action_just_pressed("next char") or (selection >= 0 and characters[selection].team != currentTeam):
		while true:
			selection = (selection + 1) % characters.size()
			if characters[selection].has_actions(currentTeam):
				break
		
	if selection != prev_selection:
		if prev_selection >= 0:
			characters[prev_selection].deselect()
		if selection >= 0:
			characters[selection].select()
	if selection >= 0:
		if Input.is_action_just_pressed("move_down"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.BACK, gridMap)
		if Input.is_action_just_pressed("move_up"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.FORWARD, gridMap)
		if Input.is_action_just_pressed("move_left"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.LEFT, gridMap)
		if Input.is_action_just_pressed("move_right"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.RIGHT, gridMap)

func _physics_process(_delta: float) -> void:
	if newRayCast:
		var space_state := get_world_3d().direct_space_state
		# look only for collisions with ground for spawning bubbles
		var query := PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd,5)
		var result := space_state.intersect_ray(query)
		
		if "position" in result:
			var clickedPosition: Vector3 = result["position"]
			var clickedNormal: Vector3 = result["normal"]
			var clickedGridPosition := gridMap.global_to_open(clickedPosition + clickedNormal * 0.1)
			
			if(selection >= 0 and characters[selection].actions > 0):
				var currentCharacter := characters[selection]
				if(currentCharacter != null):
					if(currentCharacter.classBlower and currentCharacter.position.distance_to(clickedPosition) <= bubbleRange):
						spawn_bubble(clickedGridPosition)
						currentCharacter.actions -= 1
					elif (currentCharacter.classPopper and currentCharacter.position.distance_to(clickedPosition) <= popRange):
						if(result["collider"].get_parent() is Bubble):
							result["collider"].get_parent().pop()
							currentCharacter.actions -= 1
		
		newRayCast = false

func spawn_bubble(pos: Vector3i) -> void:
	for ch in characters:
		if ch.gridPos == pos:
			# can't spawn a bubble directly on someone
			return
	var bubble: Bubble = bubbleScene.instantiate()
	bubbles.append(bubble)
	add_child(bubble)
	bubble.set_spawn(pos, gridMap)
	
func new_turn() -> void:
	currentTeam = 1 - currentTeam
	for ch in characters:
		ch.new_turn(currentTeam)

func _input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == 1:
		var from := camera.project_ray_origin(click.position)
		var normal := camera.project_ray_normal(click.position)
		rayOrigin = from
		rayEnd = from + normal * RAY_CAST_LENGTH
		newRayCast = true
