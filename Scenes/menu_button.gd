extends TextureButton

var is_focused = false

@export var from_center : bool = true
@export var highlight : Color = Color(1,1,1,.3)
@export var time : float = 0.3
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE

@export var hover_sound : AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals() # Replace with function body.

func connect_signals() -> void:
	self.mouse_entered.connect(on_hover)
	self.mouse_exited.connect(on_hover_end)
	self.focus_entered.connect(on_focus)
	self.focus_exited.connect(on_focus_end)

func add_tween(property: String, value, seconds: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, property, value, seconds).set_trans(transition_type)

func on_hover() -> void:
	hover_sound.play()
	add_tween("modulate", highlight, time)
	
func on_hover_end() -> void:
	add_tween("modulate", Color(1,1,1,1), time)

func on_focus() -> void:
	hover_sound.play()
	self.modulate = highlight
	
func on_focus_end() -> void:
	self.modulate = Color(1,1,1,1)

func sprite_flash() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "self_modulate:v", 1, 0.15).from(5)
	
	
