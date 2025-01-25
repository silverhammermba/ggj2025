class_name Character extends Node3D

@onready var animation: AnimationPlayer = $CharacterBody3D/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func deselect() -> void:
	animation.stop()

func select() -> void:
	animation.play("bob")
