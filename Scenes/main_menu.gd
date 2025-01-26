extends Control


@onready var creditsBox = %CreditsBox 
# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/VBoxContainer2/StartButton.grab_focus() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
	

func _on_options_button_pressed():
	pass # Replace with function body.


func _on_credits_button_pressed():
	if creditsBox.is_visible_in_tree() == true:
		creditsBox.visible = false
	else:
		creditsBox.visible = true# Replace with function body.
	


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://game.tscn") # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit() # Replace with function body.
