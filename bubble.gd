class_name Bubble extends Node3D
var gridPos: Vector3i = Vector3.ZERO
@onready var animation: AnimationPlayer = $AnimationPlayer

var victim : Character
var hasVictim = false

func set_spawn(pos: Vector3i, grid: Map) -> void:
	gridPos = pos
	global_position = grid.map_to_global(gridPos)

func pop() -> void:
	if(hasVictim):
		victim.bubbleVictim = false
	queue_free()
	
func push(from: Vector3i, grid: Map) -> void:
	print_debug("PUSHING")
	var dir = gridPos - from
	gridPos += dir
	global_position = grid.map_to_global(gridPos)
	if hasVictim:
		victim.gridPos += dir
		victim.global_position = grid.map_to_global(victim.gridPos)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	#if(body is Character):
	print_debug("BUBBLED: ", body.name)
	hasVictim = true
	victim = body.get_parent()
	victim.bubbleVictim = true
	#victim.reparent(self)
	victim.animation.stop()
	animation.play("bob")
