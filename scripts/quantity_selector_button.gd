extends Button

signal quantity_changed(quantity: int)

enum QuantityMode {
	ONE,
	TEN,
	HUNDRED,
	FIT,
	MAX
}

var current_mode: QuantityMode = QuantityMode.ONE
var mode_texts = ["×1", "×10", "×100", "fit", "max"]

func _ready():
	pressed.connect(_on_pressed)
	update_display()

func _on_pressed():
	# 다음 모드로 순환
	current_mode = (current_mode + 1) % QuantityMode.size()
	update_display()
	
	# 현재 모드에 따른 수량 계산은 GameManager에서 처리
	emit_signal("quantity_changed", current_mode)

func update_display():
	text = mode_texts[current_mode]

func get_quantity(current_clicks: int, base_price: int, current_level: int, price_multiplier: float) -> int:
	match current_mode:
		QuantityMode.ONE:
			return 1
		QuantityMode.TEN:
			return 10
		QuantityMode.HUNDRED:
			return 100
		QuantityMode.FIT:
			return calculate_fit_quantity(current_clicks, base_price, current_level, price_multiplier)
		QuantityMode.MAX:
			return calculate_max_quantity(current_clicks, base_price, current_level, price_multiplier)
	return 1

func calculate_fit_quantity(current_clicks: int, base_price: int, current_level: int, price_multiplier: float) -> int:
	# 현재 레벨에서 다음 10의 배수까지 구매할 수 있는 수량 계산
	var next_round_level = ((current_level / 10) + 1) * 10
	var target_quantity = next_round_level - current_level
	
	# 해당 수량을 구매할 수 있는지 확인
	var total_cost = calculate_total_cost(base_price, current_level, price_multiplier, target_quantity)
	if current_clicks >= total_cost:
		return target_quantity
	else:
		# 구매할 수 없다면 현재 구매 가능한 최대 수량 반환
		return calculate_max_quantity(current_clicks, base_price, current_level, price_multiplier)

func calculate_max_quantity(current_clicks: int, base_price: int, current_level: int, price_multiplier: float) -> int:
	var total_cost = 0
	var quantity = 0
	var current_price = base_price
	
	# 현재 레벨에서의 가격 계산
	for i in range(current_level):
		current_price = int(current_price * price_multiplier)
	
	# 구매 가능한 최대 수량 계산
	while total_cost + current_price <= current_clicks:
		total_cost += current_price
		quantity += 1
		current_price = int(current_price * price_multiplier)
	
	return max(1, quantity)

func calculate_total_cost(base_price: int, current_level: int, price_multiplier: float, quantity: int) -> int:
	var total_cost = 0
	var current_price = base_price
	
	# 현재 레벨에서의 가격 계산
	for i in range(current_level):
		current_price = int(current_price * price_multiplier)
	
	# 지정된 수량만큼의 총 비용 계산
	for i in range(quantity):
		total_cost += current_price
		current_price = int(current_price * price_multiplier)
	
	return total_cost
