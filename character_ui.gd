class_name CharacterUI extends NinePatchRect

@onready var movesText: RichTextLabel = $Char_1_TextBoxes/Char_1_Moves
@onready var actionsText: RichTextLabel = $Char_1_TextBoxes/Char_1_Actions
@onready var nameText: RichTextLabel = $NinePatchRect/Char_Name

@onready var rec: NinePatchRect = $NinePatchRect

@export var newTex: Texture2D
@export var newBox: Texture2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func updateUI(character: Character, isSelected: bool, currentTeam: int):
	var moves := "MOVES %d" % character.moves
	var actions := "ACTIONS %d" % character.actions
	
	if character.timeout > 0:
		moves = ""
		actions = "RESPAWN (%d)" % character.timeout
	elif character.bubbleVictim:
		moves = ""
		actions = "BUBBLED!"
	elif character.team != currentTeam:
		moves = ""
		actions = ""
	
	movesText.text = moves
	actionsText.text = actions
	nameText.text = character.name()
	
	scale = Vector2(1.0,1.0) if isSelected else Vector2(0.8,0.8)
	
	if character.team == 1:
		texture = newTex
		rec.texture = newBox
		nameText.rotation_degrees = -5
