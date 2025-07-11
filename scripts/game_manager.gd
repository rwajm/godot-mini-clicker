extends Node2D

var clicks: int = 0
var clicks_per_second: int = 0
var click_power: int = 1

var auto_click_price: int = 15
var click_power_price: int = 10

@onready var score_label = $CanvasLayer/UI/ScoreLabel
@onready var clicker_button = $CanvasLayer/UI/ClickerControl/ClickerButton
@onready var auto_click_button = $CanvasLayer/UI/UpgradeControl/UpgradePanel/AutoClickButton
@onready var click_power_button = $CanvasLayer/UI/UpgradeControl/UpgradePanel/ClickPowerButton

func _ready():
	update_ui()
	setup_timers()
	connect_signals()
	load_game()

func connect_signals():
	clicker_button.clicked.connect(_on_clicker_button_clicked)
	auto_click_button.upgrade_requested.connect(buy_auto_click)
	click_power_button.upgrade_requested.connect(buy_click_power)

func _on_clicker_button_clicked():
	clicks += click_power
	update_ui()

func setup_timers():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	add_child(timer)

func _on_timer_timeout():
	clicks += clicks_per_second
	update_ui()

func buy_auto_click():
	if clicks >= auto_click_price:
		clicks -= auto_click_price
		clicks_per_second += 1
		auto_click_price = int(auto_click_price * 1.5)
		update_ui()

func buy_click_power():
	if clicks >= click_power_price:
		clicks -= click_power_price
		click_power += 1
		click_power_price = int(click_power_price * 1.2)
		update_ui()

func update_ui():
	score_label.text = "클릭: " + str(clicks)
	auto_click_button.set_button_state(clicks, auto_click_price, "AutoClick")
	click_power_button.set_button_state(clicks, click_power_price, "ClickPower")

func save_game():
	var save_data = {
		"clicks": clicks,
		"clicks_per_second": clicks_per_second,
		"click_power": click_power,
		"auto_click_price": auto_click_price,
		"click_power_price": click_power_price
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
		clicks_per_second = save_data.get("clicks_per_second", 0)
		click_power = save_data.get("click_power", 1)
		auto_click_price = save_data.get("auto_click_price", 15)
		click_power_price = save_data.get("click_power_price", 10)
		update_ui()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
