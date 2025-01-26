extends TextureButton

var is_focused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.has_focus():
		sprite_flash() 
	

func sprite_flash() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "self_modulate:v", 1, 0.15).from(5)
	
	
