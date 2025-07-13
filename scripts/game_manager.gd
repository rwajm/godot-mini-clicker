extends Node2D

var clicks: int = 0
var auto_click_power: int = 0
var manual_click_power: int = 1

var auto_click_base_price: int = 15
var click_power_base_price: int = 10

var auto_click_price: int = 15
var click_power_price: int = 10

# 업그레이드 레벨 추가
var auto_click_level: int = 0
var click_power_level: int = 0

# 가격 배수
var auto_click_multiplier: float = 1.5
var click_power_multiplier: float = 1.2

@onready var score_label = $CanvasLayer/UI/ScoreLabel
@onready var clicker_button = $CanvasLayer/UI/ClickerControl/ClickerButton
@onready var auto_click_item = $CanvasLayer/UI/UpgradeControl/UpgradeVbox/UpgradePanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/AutoClickItem
@onready var click_power_item = $CanvasLayer/UI/UpgradeControl/UpgradeVbox/UpgradePanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ClickPowerItem
@onready var quantity_selector_button = $CanvasLayer/UI/UpgradeControl/UpgradeVbox/UpgradePanelContainer/VBoxContainer/QuantitySelectorButton

func _ready():
	update_ui()
	setup_timers()
	connect_signals()
	load_game()

func connect_signals():
	clicker_button.clicked.connect(_on_clicker_button_clicked)
	auto_click_item.upgrade_requested.connect(func(): buy_upgrade("auto_click"))
	click_power_item.upgrade_requested.connect(func(): buy_upgrade("click_power"))
	quantity_selector_button.quantity_changed.connect(_on_quantity_changed)

func _on_clicker_button_clicked():
	clicks += manual_click_power
	update_ui()

func setup_timers():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	add_child(timer)

func _on_timer_timeout():
	clicks += auto_click_power
	update_ui()

func _on_quantity_changed(mode):
	update_ui()

func buy_upgrade(upgrade_type: String):
	var base_price: int
	var level: int
	var multiplier: float
	var item
	
	match upgrade_type:
		"auto_click":
			base_price = auto_click_base_price
			level = auto_click_level
			multiplier = auto_click_multiplier
			item = auto_click_item
		"click_power":
			base_price = click_power_base_price
			level = click_power_level
			multiplier = click_power_multiplier
			item = click_power_item
		_:
			return
	
	var quantity = quantity_selector_button.get_quantity(clicks, base_price, level, multiplier)
	var total_cost = quantity_selector_button.calculate_total_cost(base_price, level, multiplier, quantity)
	
	if clicks >= total_cost:
		clicks -= total_cost
		
		match upgrade_type:
			"auto_click":
				auto_click_power += quantity
				auto_click_level += quantity
				# 새로운 가격 계산
				auto_click_price = auto_click_base_price
				for i in range(auto_click_level):
					auto_click_price = int(auto_click_price * auto_click_multiplier)
			"click_power":
				manual_click_power += quantity
				click_power_level += quantity
				# 새로운 가격 계산
				click_power_price = click_power_base_price
				for i in range(click_power_level):
					click_power_price = int(click_power_price * click_power_multiplier)
		
		item.upgrade_purchased(quantity)
		update_ui()

func update_ui():
	score_label.text = "클릭: " + str(clicks)
	
	var auto_click_quantity = quantity_selector_button.get_quantity(clicks, auto_click_base_price, auto_click_level, auto_click_multiplier)
	var auto_click_total_cost = quantity_selector_button.calculate_total_cost(auto_click_base_price, auto_click_level, auto_click_multiplier, auto_click_quantity)
	
	var click_power_quantity = quantity_selector_button.get_quantity(clicks, click_power_base_price, click_power_level, click_power_multiplier)
	var click_power_total_cost = quantity_selector_button.calculate_total_cost(click_power_base_price, click_power_level, click_power_multiplier, click_power_quantity)
	
	auto_click_item.set_button_state(clicks, auto_click_total_cost, "자동 클릭", auto_click_quantity)
	click_power_item.set_button_state(clicks, click_power_total_cost, "클릭 파워", click_power_quantity)

func save_game():
	var save_data = {
		"clicks": clicks,
		"auto_click_power": auto_click_power,
		"manual_click_power": manual_click_power,
		"auto_click_price": auto_click_price,
		"click_power_price": click_power_price,
		"auto_click_level": auto_click_level,
		"click_power_level": click_power_level
	}
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())
		file.close()
		clicks = save_data.get("clicks", 0)
		auto_click_power = save_data.get("auto_click_power", 0)
		manual_click_power = save_data.get("manual_click_power", 1)
		auto_click_price = save_data.get("auto_click_price", 15)
		click_power_price = save_data.get("click_power_price", 10)
		auto_click_level = save_data.get("auto_click_level", 0)
		click_power_level = save_data.get("click_power_level", 0)
		
		# 아이템의 레벨 정보 복원
		auto_click_item.current_level = auto_click_level
		click_power_item.current_level = click_power_level
		
		update_ui()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
