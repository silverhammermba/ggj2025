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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateUI(character: Character, cur: bool):
	movesText.text = "%d"%character.moves
	actionsText.text = "%d"%character.actions
	nameText.text = character.name()
	
	scale = Vector2(1.0,1.0) if cur else Vector2(0.8,0.8)
	
	if character.team == 1:
		texture = newTex
		rec.texture = newBox
		nameText.rotation_degrees = -5
