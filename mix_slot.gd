extends Panel

@export_enum("Затравка", "Наварот", "Приход") var slot_role: String = "Затравка"

var current_reagent_bottle: Panel = null
var current_tag: String = ""

@onready var combat_root = get_tree().current_scene

func _ready() -> void:
	# Находим кнопку-крестик внутри зажима, если она там есть
	var close_btn = get_node_or_null("ClearButton")
	if close_btn:
		# Привязываем клик по крестику к нашей функции очистки
		close_btn.pressed.connect(self._on_clear_button_pressed)

# 1. РАЗРЕШЕНИЕ СБРОСА: Теперь разрешаем ВСЕГДА, если мы тащим правильную пробирку
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Panel or not "reagent_data" in data:
		return false
		
	var new_cost = data.reagent_data.base_mana_cost
	var current_refund = 0
	
	# Если в зажиме уже лежит пробирка, мысленно возвращаем её стоимость в пул для расчёта
	if current_reagent_bottle:
		current_refund = current_reagent_bottle.reagent_data.base_mana_cost
		
	# Спрашиваем у менеджера, хватит ли маны с учётом возврата за старую пробирку
	return combat_root.can_afford_reagent(new_cost - current_refund)

# 2. ФИЗИЧЕСКИЙ СБРОС (ЗАМЕНА ИНГРЕДИЕНТА)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if current_reagent_bottle:
		var refund_cost = current_reagent_bottle.reagent_data.base_mana_cost
		combat_root.current_mana += refund_cost
		current_reagent_bottle.set_cooldown(false)

	current_reagent_bottle = data
	var new_cost = current_reagent_bottle.reagent_data.base_mana_cost
	combat_root.spend_mana(new_cost)
	current_reagent_bottle.set_cooldown(true)
	
	var label_node = get_node_or_null("Label")
	if label_node: label_node.text = current_reagent_bottle.reagent_data.reagent_name
		
	extract_tag_by_vector()
	
	# ВАЖНО: Просим корень обновить активность интерфейса!
	combat_root.update_slots_interactivity()

func _on_clear_button_pressed() -> void:
	if current_reagent_bottle:
		var refund_cost = current_reagent_bottle.reagent_data.base_mana_cost
		combat_root.current_mana += refund_cost
		
	clear_slot()
	# ВАЖНО: Просим корень пересчитать замки интерфейса!
	combat_root.update_slots_interactivity()
	combat_root.update_battle_screen()


func extract_tag_by_vector() -> void:
	if not current_reagent_bottle or not combat_root: return
	var is_attack = combat_root.is_attack_mode
	var data = current_reagent_bottle.reagent_data
	
	match slot_role:
		"Затравка": current_tag = data.zatravka_attack_tag if is_attack else data.zatravka_defense_tag
		"Наварот": current_tag = data.navarot_attack_tag if is_attack else data.navarot_defense_tag
		"Приход": current_tag = data.prihod_attack_tag if is_attack else data.prihod_defense_tag


# Полная тихая очистка слота (без возврата маны, вызывается при КАСТе)
func clear_slot() -> void:
	if current_reagent_bottle:
		current_reagent_bottle.set_cooldown(false)
	current_reagent_bottle = null
	current_tag = ""
	var label_node = get_node_or_null("Label")
	if label_node: 
		label_node.text = "Пусто"
