extends PanelContainer

# Эту функцию автоматически вызывает пробирка при наведении мыши
func setup_tooltip(reagent: ReagentData, is_attack: bool) -> void:
	# ЖЕСТКАЯ РУЧНАЯ ИНИЦИАЛИЗАЦИЯ: Находим узлы прямо в момент вызова функции
	var vector_icon: Label = get_node("ContentStack/VectorIcon")
	var zatravka_label: Label = get_node("ContentStack/ZatravkaLabel")
	var navarot_label: Label = get_node("ContentStack/NavarotLabel")
	var prihod_label: Label = get_node("ContentStack/PrihodLabel")
	
	# Настраиваем верхний значок режима пульта
	if is_attack:
		vector_icon.text = "⚔️ [АТАКА]"
		vector_icon.modulate = Color(1.0, 0.3, 0.3)
	else:
		vector_icon.text = "🛡️ [ЗАЩИТА]"
		vector_icon.modulate = Color(0.3, 0.6, 1.0)

	# Достаем технические теги из нашей пробирки
	var t_zatravka = reagent.zatravka_attack_tag if is_attack else reagent.zatravka_defense_tag
	var t_navarot = reagent.navarot_attack_tag if is_attack else reagent.navarot_defense_tag
	var t_prihod = reagent.prihod_attack_tag if is_attack else reagent.prihod_defense_tag

	# Собираем красивую плашку: Имя Эффекта + сгенерированное описание
	zatravka_label.text = "● " + reagent.zatravka_name.to_upper() + ":\n" + translate_effect(t_zatravka)
	navarot_label.text = "● " + reagent.navarot_name.to_upper() + ":\n" + translate_effect(t_navarot)
	prihod_label.text = "● " + reagent.prihod_name.to_upper() + ":\n" + translate_effect(t_prihod)

# Функция-переводчик: обращается напрямую к глобальному синглтону Effects
func translate_effect(tag_name: String) -> String:
	# Вызываем функции у запущенного узла Effects напрямую!
	var effects_array: Array = Effects.get_effect_data(tag_name)
	if effects_array.is_empty():
		return "Эффект еще не добавлен в базу."

	var descriptions = []
	
	for effect in effects_array:
		var line = ""
		match effect.get("type", -1):
			Effects.EffectType.PUSH:
				line = "Отталкивает цель назад на " + str(effect.get("power", 1)) + " поз."
			Effects.EffectType.PULL:
				line = "Притягивает цель вперед на " + str(effect.get("power", 1)) + " поз."
			Effects.EffectType.DAMAGE:
				line = "Наносит " + str(effect.get("power", 0)) + " ед. урона (" + get_damage_name(effect.get("damage", 0)) + ")"
			Effects.EffectType.BARRIER:
				line = "Создает препятствие (Прочность: " + str(effect.get("power", 0)) + ")"
			Effects.EffectType.ZONE:
				line = "Создает аномальную зону на " + str(effect.get("duration", 1)) + " х. " + get_status_name(effect.get("status", 0))
			Effects.EffectType.SHIELD:
				line = "Выставляет щит (Снижение урона на " + str(effect.get("damage_reduce_percent", 0.0) * 100) + "%)"
			Effects.EffectType.COUNTER_ATTACK:
				line = "Готовит ответный удар при получении урона"
			Effects.EffectType.BUFF:
				line = "Накладывает статус: " + get_status_name(effect.get("status", 0))
			Effects.EffectType.DEBUFF:
				line = "Накладывает дебафф: " + get_status_name(effect.get("status", 0))
			Effects.EffectType.DISCOUNT_NAVAROT:
				line = "Снижает стоимость Наварота на " + str(effect.get("value", 0)) + " маны"
			_:
				line = "Активирует скрытую алхимическую реакцию"
				
		descriptions.append(line)
		
	return ", ".join(descriptions)

# Вспомогательный переводчик типов урона
func get_damage_name(type_value: int) -> String:
	match type_value:
		Effects.DamageType.EXPLOSION: return "Взрыв"
		Effects.DamageType.FIRE: return "Огонь"
		Effects.DamageType.ACID: return "Кислота"
		Effects.DamageType.TAR: return "Удушение смолой"
		Effects.DamageType.CHEMICAL: return "Химический ожог"
		_: return "Физический"

# Вспомогательный переводчик названий статусов
func get_status_name(status_value: int) -> String:
	match status_value:
		Effects.EffectStatus.CRIT: return "[Уязвимость к Криту]"
		Effects.EffectStatus.INVULNERABLE: return "[Неуязвимость]"
		Effects.EffectStatus.POWDER_BARRIER: return "[Пороховой заслон]"
		Effects.EffectStatus.BURNING_ZONE: return "[Горящая клетка]"
		Effects.EffectStatus.POWDER_SHIELD: return "[Щит Пороха]"
		Effects.EffectStatus.GUNPOWDER_DEBUFF: return "[Взрывоопасный след]"
		Effects.EffectStatus.STUN: return "[Оглушение]"
		Effects.EffectStatus.ROOT: return "[Корни / Обездвиживание]"
		Effects.EffectStatus.GUNPOWDER_TRAIL: return "[Пороховой след героя]"
		_: return "[Активный след]"
