extends PanelContainer

signal upgrade_requested

@onready var name_label = $HBoxContainer/VBoxContainer/NameLabel
@onready var level_label = $HBoxContainer/VBoxContainer/LevelLabel
@onready var upgrade_button = $HBoxContainer/UpgradeButton
@onready var quantity_label = $HBoxContainer/UpgradeButton/PanelContainer/HBoxContainer/QuantityLabel
@onready var cost_label = $HBoxContainer/UpgradeButton/PanelContainer/HBoxContainer/CostLabel

var current_level: int = 0
var item_name: String = ""

func _ready():
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)

func _on_upgrade_button_pressed():
	emit_signal("upgrade_requested")

func set_button_state(current_clicks: int, price: int, upgrade_name: String, quantity: int):
	item_name = upgrade_name
	name_label.text = upgrade_name
	level_label.text = "Lv. %d" % current_level
	quantity_label.text = "×%d" % quantity
	cost_label.text = str(price)
	
	# 구매 가능 여부에 따라 버튼 상태 변경
	upgrade_button.disabled = current_clicks < price
	
	# 구매 가능 여부에 따라 색상 변경
	if current_clicks >= price:
		cost_label.modulate = Color.WHITE
		upgrade_button.modulate = Color.WHITE
	else:
		cost_label.modulate = Color.GRAY
		upgrade_button.modulate = Color.GRAY

func upgrade_purchased(quantity: int):
	current_level += quantity
	level_label.text = "Lv. %d" % current_level
