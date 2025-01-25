class_name Character extends Node3D

@onready var animation: AnimationPlayer = $CharacterBody3D/AnimationPlayer

func deselect() -> void:
	animation.stop()

func select() -> void:
	animation.play("bob")
