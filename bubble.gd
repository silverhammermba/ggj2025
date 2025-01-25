class_name Bubble extends Node3D
var gridPos: Vector3i = Vector3.ZERO
@onready var animation: AnimationPlayer = $AnimationPlayer
	
func set_spawn(pos: Vector3i, grid: Map) -> void:
	gridPos = pos
	global_position = grid.map_to_global(gridPos)

func _on_area_3d_body_entered(body: Node3D) -> void:
	#if(body is Character):
	print_debug("BUBBLED: ", body.name)
	var victim = body.get_parent()
	victim.bubbleVictim = true
	victim.reparent(self)
	victim.animation.stop()
	animation.play("bob")
