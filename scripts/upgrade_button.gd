extends Button

signal upgrade_requested

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	emit_signal("upgrade_requested")

func set_button_state(current_clicks: int, price: int, label: String):
	text = "%s (%d)" % [label, price]
	disabled = current_clicks < price
