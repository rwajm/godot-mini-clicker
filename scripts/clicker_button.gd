extends Button

signal clicked

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	emit_signal("clicked")
