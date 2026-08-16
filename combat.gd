extends Control

@onready var vector_button: Button = %VectorButton
@onready var slot_zatravka = %Zatravka
@onready var slot_navarot = %Navarot
@onready var slot_prihod = %Prihod
@onready var hero_block: Panel = %HeroBlock
@onready var enemy_block: Panel = %EnemyBlock

# Переводим кнопки очистки и каста на чистые Уникальные Имена (%)
@onready var clear_all_button: Button = %ClearAllButton
@onready var cast_button: Button = %CastButton

# Ссылка на наше уникальное окошко итогов заклинания
@onready var summary_label: Label = %SummaryPanel/SummaryLabel

var hero_hp_label: Label
var enemy_hp_label: Label
var mana_label: Label
var hero_status_container: HBoxContainer
var enemy_status_container: HBoxContainer

# Параметры боя
var hero_hp: int = 50
var enemy_hp: int = 40
var max_mana: int = 4
var current_mana: int = 4
var is_attack_mode: bool = true

# КООРДИНАТНАЯ СЕТКА: ТАКТИЧЕСКИЕ ЛИНИИ
var position_coordinates: Array = [100.0, 350.0, 600.0, 850.0, 1100.0]
var hero_position_index: int = 1
var enemy_position_index: int = 3

func _ready() -> void:
	if hero_block: 
		hero_hp_label = hero_block.get_node("HPLabel")
		hero_status_container = hero_block.get_node("StatusIcons")
	if enemy_block: 
		enemy_hp_label = enemy_block.get_node("HPLabel")
		enemy_status_container = enemy_block.get_node("StatusIcons")
		
	if clear_all_button: clear_all_button.pressed.connect(self._on_clear_all_button_pressed)
	if cast_button: cast_button.pressed.connect(self._on_cast_button_pressed)
	
	mana_label = Label.new()
	mana_label.name = "ManaLabel"
	$MainSplitter/AlchemistBelt.add_child(mana_label)
	mana_label.position = Vector2(40, 20)
	
	if vector_button:
		vector_button.text = "АТАКА"
		vector_button.modulate = Color(1.0, 0.2, 0.2)
		
	update_positions_on_screen()
	update_slots_interactivity()
	update_battle_screen()

func update_positions_on_screen() -> void:
	if hero_block: hero_block.position.x = position_coordinates[hero_position_index]
	if enemy_block: enemy_block.position.x = position_coordinates[enemy_position_index]

func update_battle_screen() -> void:
	if hero_hp_label: hero_hp_label.text = "ГЕРОЙ (Поз: " + str(hero_position_index) + ")\nHP: " + str(hero_hp) + "/50"
	if enemy_hp_label: enemy_hp_label.text = "ВРАГ (Поз: " + str(enemy_position_index) + ")\nHP: " + str(enemy_hp) + "/40"
	if mana_label:
		mana_label.text = "ЭНЕРГИЯ: " + str(current_mana) + "/" + str(max_mana)
		mana_label.modulate = Color(0.3, 0.7, 1.0)

func can_afford_reagent(cost: int) -> bool:
	return current_mana >= cost

func spend_mana(cost: int) -> void:
	current_mana = max(0, current_mana - cost)
	update_battle_screen()
# УМНЫЙ ЭКРАН ИТОГОВ: Считает эффекты со всех зажимов и выводит в окошко
func update_spell_summary() -> void:
	if not summary_label:
		return
		
	if slot_zatravka.current_tag == "":
		summary_label.text = "АППАРАТ СНА ПУСТ\nЗадайте Затравку"
		return
		
	# Вытаскиваем массивы из базы Effects
	var z_eff = Effects.get_effect_data(slot_zatravka.current_tag)
	var n_eff = Effects.get_effect_data(slot_navarot.current_tag) if slot_navarot.current_tag != "" else []
	var p_eff = Effects.get_effect_data(slot_prihod.current_tag) if (slot_prihod.current_tag != "" and slot_navarot.current_tag != "") else []
	
	# ФИКС ОШИБКИ: Безопасно берем цель из первого словаря массива Затравки
	var target_type = Effects.TargetType.ENEMY
	if not z_eff.is_empty():
		var first_dict = z_eff[0]
		target_type = first_dict.get("target", Effects.TargetType.ENEMY)
		
	var target_name = get_target_name_string(target_type)
	
	# Считаем суммарный урон и собираем статусы по цепочке
	var total_damage = 0
	var statuses = []
	
	# Собираем данные со всей алхимической цепи
	for arr in [z_eff, n_eff, p_eff]:
		for eff in arr:
			if eff.get("type", -1) == Effects.EffectType.DAMAGE:
				total_damage += eff.get("power", 0)
			if eff.get("type", -1) in [Effects.EffectType.DEBUFF, Effects.EffectType.BUFF]:
				statuses.append(get_status_string(eff.get("status", -1)))
				
	# Генерируем красивый текст для окошка итогов
	var info = ""
	info += "ЦЕЛЬ: " + target_name.to_upper() + "\n"
	if total_damage > 0:
		info += "ОБЩИЙ УРОН: " + str(total_damage) + " ЕД.\n"
	if not statuses.is_empty():
		info += "ЭФФЕКТЫ: " + ", ".join(statuses) + "\n"
	else:
		info += "ЧИСТАЯ ГЕОМЕТРИЯ ПОЛЯ"
		
	summary_label.text = info

func update_slots_interactivity() -> void:
	var has_zatravka = slot_zatravka.current_tag != ""
	var z_close = slot_zatravka.get_node_or_null("ClearButton")
	if z_close: z_close.visible = has_zatravka
	if cast_button: cast_button.disabled = not has_zatravka
	
	if has_zatravka:
		slot_navarot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot_navarot.modulate.a = 1.0
	else:
		slot_navarot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_navarot.modulate.a = 0.3
		
	var has_navarot = slot_navarot.current_tag != ""
	var n_close = slot_navarot.get_node_or_null("ClearButton")
	if n_close: n_close.visible = has_navarot
	
	if has_navarot:
		slot_prihod.mouse_filter = Control.MOUSE_FILTER_STOP
		slot_prihod.modulate.a = 1.0
	else:
		slot_prihod.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_prihod.modulate.a = 0.3
		
	var has_prihod = slot_prihod.current_tag != ""
	var p_close = slot_prihod.get_node_or_null("ClearButton")
	if p_close: p_close.visible = has_prihod
	
	update_spell_summary()

func _on_clear_all_button_pressed() -> void:
	if slot_zatravka.has_method("_on_clear_button_pressed"):
		slot_zatravka._on_clear_button_pressed()
		slot_navarot._on_clear_button_pressed()
		slot_prihod._on_clear_button_pressed()
	update_slots_interactivity()
	update_battle_screen()

func _on_vector_button_pressed() -> void:
	is_attack_mode = !is_attack_mode
	vector_button.text = "АТАКА" if is_attack_mode else "ЗАЩИТА"
	vector_button.modulate = Color(1.0, 0.2, 0.2) if is_attack_mode else Color(0.2, 0.5, 1.0)
	if slot_zatravka.current_tag != "": slot_zatravka.extract_tag_by_vector()
	if slot_navarot.current_tag != "": slot_navarot.extract_tag_by_vector()
	if slot_prihod.current_tag != "": slot_prihod.extract_tag_by_vector()
	update_spell_summary()

func _on_cast_button_pressed() -> void:
	if slot_zatravka.current_tag == "": return
	clear_status_displays()
		
	var zatravka_effects: Array = Effects.get_effect_data(slot_zatravka.current_tag)
	var navarot_effects: Array = []
	var prihod_effects: Array = []
	
	var has_navarot = slot_navarot.current_tag != ""
	if has_navarot:
		navarot_effects = Effects.get_effect_data(slot_navarot.current_tag)
		if slot_prihod.current_tag != "":
			prihod_effects = Effects.get_effect_data(slot_prihod.current_tag)
	
	# ФИКС ОШИБКИ: Точно так же безопасно берем цель при касте комбо
	var final_target = Effects.TargetType.ENEMY
	if not zatravka_effects.is_empty():
		var first_dict = zatravka_effects[0]
		final_target = first_dict.get("target", Effects.TargetType.ENEMY)
	
	apply_effect_chain(zatravka_effects, final_target, "ЗАТРАВКА")
	if not navarot_effects.is_empty(): apply_effect_chain(navarot_effects, final_target, "НАВАРОТ")
	if not prihod_effects.is_empty() and has_navarot: apply_effect_chain(prihod_effects, final_target, "ПРИХОД")
	
	current_mana = max_mana
	update_positions_on_screen()
	
	slot_zatravka.clear_slot()
	slot_navarot.clear_slot()
	slot_prihod.clear_slot()
	
	update_slots_interactivity()
	update_battle_screen()

func apply_effect_chain(effects_array: Array, target_type: int, stage_name: String) -> void:
	for effect in effects_array:
		var eff_type = effect.get("type", -1)
		match eff_type:
			Effects.EffectType.DAMAGE:
				var dmg = effect.get("power", 0)
				if target_type == Effects.TargetType.ENEMY or target_type == Effects.TargetType.ALL_ENEMIES:
					enemy_hp = max(0, enemy_hp - dmg)
				else:
					hero_hp = max(0, hero_hp - dmg)
			Effects.EffectType.PUSH:
				var dist = effect.get("power", 1)
				if target_type == Effects.TargetType.ENEMY or target_type == Effects.TargetType.ALL_ENEMIES:
					enemy_position_index = min(4, enemy_position_index + dist)
				else:
					hero_position_index = max(0, hero_position_index - dist)
			Effects.EffectType.PULL:
				var dist = effect.get("power", 1)
				if target_type == Effects.TargetType.ENEMY or target_type == Effects.TargetType.ALL_ENEMIES:
					enemy_position_index = max(0, enemy_position_index - dist)
				else:
					hero_position_index = min(4, hero_position_index + dist)
			Effects.EffectType.DEBUFF, Effects.EffectType.BUFF:
				var status_id = effect.get("status", -1)
				spawn_status_icon(target_type, status_id)

func clear_status_displays() -> void:
	if hero_status_container:
		for child in hero_status_container.get_children(): child.queue_free()
	if enemy_status_container:
		for child in enemy_status_container.get_children(): child.queue_free()

func spawn_status_icon(target_type: int, status_id: int) -> void:
	var status_label = Label.new()
	status_label.text = " [" + get_status_string(status_id) + "] "
	if status_id in [Effects.EffectStatus.CRIT, Effects.EffectStatus.STUN, Effects.EffectStatus.GUNPOWDER_DEBUFF]:
		status_label.modulate = Color(1.0, 0.4, 0.4)
	else:
		status_label.modulate = Color(0.4, 1.0, 0.4)
	if target_type == Effects.TargetType.ENEMY or target_type == Effects.TargetType.ALL_ENEMIES:
		if enemy_status_container: enemy_status_container.add_child(status_label)
	else:
		if hero_status_container: hero_status_container.add_child(status_label)

func get_status_string(status_value: int) -> String:
	match status_value:
		Effects.EffectStatus.CRIT: return "КРИТ"
		Effects.EffectStatus.INVULNERABLE: return "НЕУЯЗВ"
		Effects.EffectStatus.POWDER_BARRIER: return "ЗАСЛОН"
		Effects.EffectStatus.BURNING_ZONE: return "ОГОНЬ"
		Effects.EffectStatus.STUN: return "СТАН"
		Effects.EffectStatus.ROOT: return "КОРНИ"
		Effects.EffectStatus.GUNPOWDER_TRAIL: return "СЛЕД_ГЕРОЯ"
		Effects.EffectStatus.GUNPOWDER_DEBUFF: return "СЛЕД_ВРАГА"
		_: return "СТАТУС_" + str(status_value)

func get_target_name_string(target_enum_value: int) -> String:
	match target_enum_value:
		Effects.TargetType.ENEMY: return "Враг"
		Effects.TargetType.ALL_ENEMIES: return "Ряд Врагов"
		Effects.TargetType.ALLY: return "Союзник"
		Effects.TargetType.SELF: return "Герой"
		_: return "Позиция"
