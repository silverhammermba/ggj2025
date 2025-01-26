class_name CharacterModel extends Node3D

@onready var animations: AnimationPlayer = $AnimationPlayer


func walk() -> void:
	animations.play("WalkCycle")
	
func pop() -> void:
	animations.play("Pop")

func push() -> void:
	animations.play("Push")
	
func blow() -> void:
	animations.play("BubbleBlow")

func idle() -> void:
	animations.play("Idle")
	
func stop() -> void:
	animations.stop()
