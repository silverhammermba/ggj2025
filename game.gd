class_name Game extends Node3D

@onready var gridMap: Map = $map
@onready var camera: Camera3D = $"camera pivot/Camera3D"
@onready var uiLabel: Label = $Control/Label

@export var RAY_CAST_LENGTH := 1000
@export var bubbleScene : PackedScene
@export var bubbleRange = 3
@export var popRange = 2
@export var pushRange = 1
@export var pushDistance = 2

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
		# snap chars to grid and set them on the floor
		ch.setPos(gridMap.global_to_map(ch.global_position), gridMap)
		ch.fall(gridMap)
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
	elif Input.is_action_just_pressed("next char") or selection < 0 or !characters[selection].has_actions(currentTeam):
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
			currentCharacter.move(currentCharacter.gridPos + Vector3i.BACK, gridMap, characters)
		if Input.is_action_just_pressed("move_up"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.FORWARD, gridMap, characters)
		if Input.is_action_just_pressed("move_left"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.LEFT, gridMap, characters)
		if Input.is_action_just_pressed("move_right"):
			var currentCharacter = characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.RIGHT, gridMap, characters)
	update_ui()

func _physics_process(_delta: float) -> void:
	if newRayCast:
		newRayCast = false
		if selection < 0 or characters[selection] == null or characters[selection].actions <= 0:
			return
			
		var currentCharacter := characters[selection]
		
		# blowers need ground, poppers/pushers need bubbles
		var mask = 1 if currentCharacter.classBlower else 4
		
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, mask)
		var result := space_state.intersect_ray(query)
		
		if "position" in result:
			var clickedPosition: Vector3 = result["position"]
			var clickedNormal: Vector3 = result["normal"]
			
			if(!currentCharacter.bubbleVictim):
				if currentCharacter.classBlower:
					var clickedGridPosition := gridMap.global_to_open(clickedPosition + clickedNormal * 0.1)
					if currentCharacter.grid_dist(clickedGridPosition) <= bubbleRange:
						if spawn_bubble(clickedGridPosition):
							currentCharacter.actions -= 1
							currentCharacter.model.blow()
				else:
					var bubble := result["collider"].get_parent() as Bubble
					if currentCharacter.classPopper and currentCharacter.grid_dist(bubble.gridPos) <= popRange:
						bubble.pop(gridMap)
						currentCharacter.actions -= 1
						currentCharacter.model.pop()
					elif (currentCharacter.classPusher and currentCharacter.grid_dist(bubble.gridPos) <= pushRange):
						bubble.push(currentCharacter.gridPos, gridMap)
						currentCharacter.actions -= 1
						currentCharacter.model.push()

func spawn_bubble(pos: Vector3i) -> bool:
	for ch in characters:
		if ch.gridPos == pos:
			# can't spawn a bubble directly on someone
			return false
	for bubble in bubbles:
		if is_instance_valid(bubble) and bubble.gridPos == pos:
			# can't spawn bubble on a bubble
			return false
	var bubble: Bubble = bubbleScene.instantiate()
	bubbles.append(bubble)
	add_child(bubble)
	bubble.set_spawn(pos, gridMap)
	return true
	
func new_turn() -> void:
	currentTeam = 1 - currentTeam
	for ch in characters:
		if ch.new_turn(currentTeam):
			while true:
				var gridPos := Vector3i(randi_range(-2, 5), 0, randi_range(-2, 5))
				while gridMap.get_cell_item(gridPos) != -1:
					gridPos.y += 1
				var occupied := false
				for other in characters:
					if other.gridPos == gridPos:
						occupied = true
						break
				if occupied:
					continue
				for bubble in bubbles:
					if is_instance_valid(bubble) and bubble.gridPos == gridPos:
						occupied = true
						break
				if occupied:
					continue
				ch.setPos(gridPos, gridMap)
				break
				
	for victimBubble in bubbles:
		if(is_instance_valid(victimBubble) and victimBubble.hasVictim and victimBubble.victim.team == currentTeam):
			victimBubble.liveSpindown(gridMap)

func _input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == 1:
		var from := camera.project_ray_origin(click.position)
		var normal := camera.project_ray_normal(click.position)
		rayOrigin = from
		rayEnd = from + normal * RAY_CAST_LENGTH
		newRayCast = true
		
func update_ui() -> void:
	var ui := "Team "
	ui += "Green" if currentTeam == 0 else "Blue"
	for idx in range(0, characters.size()):
		var ch := characters[idx]
		if ch.team != currentTeam:
			continue
		var presel := ("> " if idx == selection else "")
		var postsel := (" <" if idx == selection else "")
		ui += "\n%s%s%s" % [presel, ch.status(), postsel]
	uiLabel.text = ui
		
