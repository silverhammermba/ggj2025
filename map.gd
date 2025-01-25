extends Node3D

var characters: Array[Character] = []
var selection := -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chars = get_tree().get_nodes_in_group("character")
	
	for ch in chars:
		assert(ch is Character)
		characters.append(ch)


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
		
