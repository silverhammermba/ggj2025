class_name Game extends Node3D

var myNewScene = preload("res://game.tscn")

@onready var gridMap: Map = $map
@onready var camera: Camera3D = $"camera pivot/Camera3D"

@onready var p1UI: CharacterUI = $GameUI/GUI/HBoxContainer3/Player_1_Margin/Player_1_Container/Char_1
@onready var p2UI: CharacterUI = $GameUI/GUI/HBoxContainer3/Player_1_Margin/Player_1_Container/Char_2
@onready var p3UI: CharacterUI = $GameUI/GUI/HBoxContainer3/Player_1_Margin/Player_1_Container/Char_3
@onready var p4UI: CharacterUI = $GameUI/GUI/HBoxContainer3/Player_2_Margin/Player_2_Container/Char_4
@onready var p5UI: CharacterUI = $GameUI/GUI/HBoxContainer3/Player_2_Margin/Player_2_Container/Char_5
@onready var p6UI: CharacterUI = $GameUI/GUI/HBoxContainer3/Player_2_Margin/Player_2_Container/Char_6

@onready var p1Arrow: NinePatchRect = $GameUI/GUI/HBoxContainer3/Arrow_Margin/HBoxContainer/Player_1_Arrow
@onready var p2Arrow: NinePatchRect = $GameUI/GUI/HBoxContainer3/Arrow_Margin/HBoxContainer/Player_2_Arrow

@onready var optionsMenu: Control = $OptionsLayer/OptionsMenu
@onready var continueButton: TextureButton = $OptionsLayer/OptionsMenu/MarginContainer/VBoxContainer/ContinueMarginContainer/ContinueButton
@onready var restartButton: TextureButton = $OptionsLayer/OptionsMenu/MarginContainer/VBoxContainer/RestartMarginContainer/RestartButton
@onready var quitButton: TextureButton = $OptionsLayer/OptionsMenu/MarginContainer/VBoxContainer/QuitMarginContainer/QuitButton


@export var RAY_CAST_LENGTH := 1000
@export var bubbleScene : PackedScene
@export var bubbleRange = 3
@export var popRange = 2
@export var pushRange = 2
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
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	var prev_selection := selection
	
	var has_actions := false
	for ch in characters:
		if ch.has_actions(currentTeam):
			has_actions = true
			break
	if !has_actions or Input.is_action_just_pressed("end_turn"):
		$FinalizeTurnSFX.play()
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
		$MenuHoverSFX.play()
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
		$MenuHoverSFX.play()
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
			if currentCharacter.moves > 0:
				$MovementSFX.play()
			currentCharacter.move(currentCharacter.gridPos + Vector3i.BACK, gridMap, characters)
		if Input.is_action_just_pressed("move_up"):
			var currentCharacter = characters[selection]
			if currentCharacter.moves > 0:
				$MovementSFX.play()
			currentCharacter.move(currentCharacter.gridPos + Vector3i.FORWARD, gridMap, characters)
		if Input.is_action_just_pressed("move_left"):
			var currentCharacter = characters[selection]
			if currentCharacter.moves > 0:
				$MovementSFX.play()
			currentCharacter.move(currentCharacter.gridPos + Vector3i.LEFT, gridMap, characters)
		if Input.is_action_just_pressed("move_right"):
			var currentCharacter = characters[selection]
			if currentCharacter.moves > 0:
				$MovementSFX.play()
			currentCharacter.move(currentCharacter.gridPos + Vector3i.RIGHT, gridMap, characters)
	update_ui()

func _physics_process(_delta: float) -> void:
	if newRayCast:
		newRayCast = false
		if selection < 0 or characters[selection] == null:
			return
			
		var currentCharacter := characters[selection]
		
		if currentCharacter.actions <= 0 or currentCharacter.bubbleVictim or currentCharacter.team != currentTeam:
			return
		
		var space_state := get_world_3d().direct_space_state
		var groundQuery := PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, 1)
		var groundResult := space_state.intersect_ray(groundQuery)
		var bubbleQuery := PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, 4)
		var bubbleResult := space_state.intersect_ray(bubbleQuery)
		
		if currentCharacter.classBlower or currentCharacter.classEnemyBlower:
			if "position" not in groundResult:
				return
			var clickedPosition: Vector3 = groundResult["position"]
			var clickedNormal: Vector3 = groundResult["normal"]
			var clickedGridPosition := gridMap.global_to_open(clickedPosition + clickedNormal * 0.1)
			if currentCharacter.grid_dist(clickedGridPosition) <= bubbleRange:
				if spawn_bubble(clickedGridPosition):
					currentCharacter.actions -= 1
					currentCharacter.model.blow()
		elif currentCharacter.classPopper or currentCharacter.classEnemyPopper:
			if "position" not in bubbleResult:
				return
			var bubble := bubbleResult["collider"].get_parent() as Bubble
			if currentCharacter.grid_dist(bubble.gridPos) <= popRange:
				bubble.pop(gridMap)
				currentCharacter.actions -= 1
				currentCharacter.model.pop()
		elif currentCharacter.classPusher or currentCharacter.classEnemyPusher:
			if "position" in bubbleResult:
				var bubble := bubbleResult["collider"].get_parent() as Bubble
				if currentCharacter.grid_dist(bubble.gridPos) <= pushRange:
					bubble.push(currentCharacter.gridPos, gridMap, bubbles)
					currentCharacter.actions -= 1
					currentCharacter.model.push()
			elif "position" in groundResult:
				var clickedPosition: Vector3 = groundResult["position"]
				var clickedNormal: Vector3 = groundResult["normal"]
				var clickedGridPosition := gridMap.global_to_open(clickedPosition + clickedNormal * 0.1)
				for ch in characters:
					if ch != self and ch.gridPos == clickedGridPosition:
						if ch.push(currentCharacter.gridPos, gridMap, characters):
							currentCharacter.actions -= 1
							currentCharacter.model.push()
		elif currentCharacter.generalist:
			#Generalist with selector for skills
			if currentCharacter.generalist_selector == 0:
				if "position" not in groundResult:
					return
				var clickedPosition: Vector3 = groundResult["position"]
				var clickedNormal: Vector3 = groundResult["normal"]
				var clickedGridPosition := gridMap.global_to_open(clickedPosition + clickedNormal * 0.1)
				if currentCharacter.grid_dist(clickedGridPosition) <= bubbleRange:
					if spawn_bubble(clickedGridPosition):
						currentCharacter.actions -= 1
						currentCharacter.model.blow()
			elif currentCharacter.generalist_selector == 1:
				if "position" not in bubbleResult:
					return
				var bubble := bubbleResult["collider"].get_parent() as Bubble
				if currentCharacter.grid_dist(bubble.gridPos) <= popRange:
					bubble.pop(gridMap)
					currentCharacter.actions -= 1
					currentCharacter.model.pop()
			elif currentCharacter.generalist_selector == 2:
				if "position" in bubbleResult:
					var bubble := bubbleResult["collider"].get_parent() as Bubble
					if currentCharacter.grid_dist(bubble.gridPos) <= pushRange:
						bubble.push(currentCharacter.gridPos, gridMap, bubbles)
						currentCharacter.actions -= 1
						currentCharacter.model.push()
				elif "position" in groundResult:
					var clickedPosition: Vector3 = groundResult["position"]
					var clickedNormal: Vector3 = groundResult["normal"]
					var clickedGridPosition := gridMap.global_to_open(clickedPosition + clickedNormal * 0.1)
					for ch in characters:
						if ch != self and ch.gridPos == clickedGridPosition:
							if ch.push(currentCharacter.gridPos, gridMap, characters):
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
	if currentTeam != 0:
		p1Arrow.modulate = Color(0,0,0,0)
		p2Arrow.modulate = Color(1,1,1,1)
	else:
		p2Arrow.modulate = Color(0,0,0,0)
		p1Arrow.modulate = Color(1,1,1,1)
	
	var charUIs: Array[CharacterUI] = [p1UI,p2UI,p3UI,p4UI,p5UI,p6UI]
	for idx in range(0, characters.size()):
		var ch := characters[idx]
		charUIs[idx].updateUI(ch, idx == selection, currentTeam)
	
	if Input.is_action_just_released("ui_cancel") and optionsMenu.visible != true:
		optionsMenu.visible = true
		#get_tree().paused = true
		print("open")
	elif Input.is_action_just_released("ui_cancel") and optionsMenu.visible != false:
		optionsMenu.visible = false
		#get_tree().paused = false
		print("closed")

func pause_game():
	optionsMenu.visible = true
	get_tree().paused
	#if continueButton.pressed:
		#close_menu()
	#if restartButton.pressed:
		#pass
	#if quitButton.pressed:
		#pass	
		#
#func open_menu() -> void:
	#optionsMenu.visible = true
	#
#func close_menu() -> void:
	#optionsMenu.visible = false
	
