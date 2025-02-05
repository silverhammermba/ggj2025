extends Control

@onready var creditsBox = %CreditsBox 
# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/VBoxContainer2/StartButton.grab_focus() # Replace with function body.

func _on_options_button_pressed():
	$SelectSFX.play()
	pass # Replace with function body.


func _on_credits_button_pressed():
	if creditsBox.is_visible_in_tree() == true:
		$DeSelectSFX.play()
		creditsBox.visible = false
	else:
		$SelectSFX.play()
		creditsBox.visible = true# Replace with function body.

func _on_start_button_pressed():
	$SelectSFX.play()
	get_tree().change_scene_to_file("res://game.tscn") # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit() # Replace with function body.
