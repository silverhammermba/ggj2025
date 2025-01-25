class_name Game extends Node3D

@onready var gridMap: GridMap = $map
@onready var rayCast: RayCast3d = $rayCaster
@onready var camera: Camera3D = $"camera pivot/Camera3D"

var characters: Array[Character] = []
var selection := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chars = get_tree().get_nodes_in_group("character")
	
	for ch in chars:
		assert(ch is Character)
		characters.append(ch)
		ch.move(gridMap.local_to_map(gridMap.to_local((ch as Node3D).position)),gridMap)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var prev_selection := selection
	
	if Input.is_action_just_pressed("next char"):
		selection += 1
		if characters.size() > 0:
			selection = selection % characters.size()
		else:
			selection = -1
	if Input.is_action_just_pressed("prev char"):
		if selection >= 0:
			selection -= 1
			if selection < 0:
				selection = characters.size() - 1
		else:
			selection = characters.size() - 1
		
	if selection != prev_selection:
		if prev_selection >= 0:
			characters[prev_selection].deselect()
		if selection >= 0:
			characters[selection].select()
	if selection >= 0:
		if Input.is_action_just_pressed("move_down"):
			var  currentCharacter := characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.BACK, gridMap)
		if Input.is_action_just_pressed("move_up"):
			var  currentCharacter := characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.FORWARD, gridMap)
		if Input.is_action_just_pressed("move_left"):
			var  currentCharacter := characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.LEFT, gridMap)
		if Input.is_action_just_pressed("move_right"):
			var  currentCharacter := characters[selection]
			currentCharacter.move(currentCharacter.gridPos + Vector3i.RIGHT, gridMap)
		
			
func _physics_process(_delta: float) -> void:
	pass

func _input(event):
	if event is Input.is_action_just_pressed("bubble"):
		var from = camera.project_ray_origin()
			#rayCast.
