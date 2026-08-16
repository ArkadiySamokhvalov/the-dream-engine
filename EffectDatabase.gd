# EffectDatabase.gd
extends Node

enum TargetType {
	ENEMY,        # Одиночный враг
	ALL_ENEMIES,  # Все враги в ряду
	ALLY,         # Одиночный союзник
	SELF,         # Строго сам Протагонист
	ALL_ALLIES,   # Вся команда игрока
	POSITION,     # Позиция на своей стороне
}

enum EffectType {
	PUSH,             # Сдвиг на позицию назад
	PULL,             # Сдвиг на позицию вперёд
	BUFF,             # Положительный эффект статус-эффекта
	DEBUFF,           # Отрицательный эффект статус-эффекта
	DISCOUNT_NAVAROT, # Удешевляет наварот
	DAMAGE,           # Чистый урон
	BARRIER,          # Создает препятствие
	ZONE,             # Создаёт зону на позиции
	SHIELD,           # Создаёт щит со снижением урона
	COUNTER_ATTACK,   # Ответное действие при получении удара
	CLEANSE,          # Снятие негативных/позитивных эффектов
	STEAL_BUFF,       # Украсть бафф у врага и отдать себе
	REFUND_REAGENT,   # Случайный реагент возвращается в руку
}

enum EffectStatus {
	INVULNERABLE,       # Неуязвимость к следующей атаке
	CRIT,               # Следующий урон +50%
	POWDER_BARRIER,     # Препятствие-щит: полная блокировка атак по позиции
	BURNING_ZONE,       # Огонь на клетке
	POWDER_SHIELD,      # Щит пороха (-50% урона и наложение следа при ударе)
	ROOT,               # Запрещает передвижение
	STUN,               # Пропуск хода
	GUNPOWDER_TRAIL,    # Пермобафф героя: атаки накладывают пороховой след
	GUNPOWDER_DEBUFF,   # Взрывоопасный пороховой след на враге
	
	# Волшебные статусы
	REGENERATION,       # Исцеление в начале хода
	CORROSION,          # Периодический некротический урон / корни
	WOOD_ARMOR,         # Прочная кора (+30% к защите от физ. атак)
	INVISIBILITY,       # Скрытность (враги мажут)
	BLIND,              # Ослепление (промах следующей атакой)
	ASH_CLOUD,          # Облако уклонения (или завеса праха)
	
	# Новые волшебные статусы
	PHASE_SHIFT,        # Фазовый сдвиг (цель неосязаема: её нельзя атаковать, но и она не может атаковать)
	ISOLATION_ZONE,     # Изолирующий барьер на клетке (блокирует входящий AoE-урон)
	WEAKNESS,           # Слабость (-25% к наносимому урону)
	CHAOS_INVERSION,    # Инверсия (баффы цели превращаются в дебаффы аналогичной силы)
	RANDOM_MADNESS,     # Хаотическое безумие (цель бьет случайное существо на поле)
	
	# Земные статусы
	MELTED_ARMOR,       # Разъеденная броня (+50% к получаемому физ. урону)
	ACID_TRAIL,         # Пермобафф героя: атаки режут броню цели на 10% навсегда
	TAR_ZONE,           # Вязкая лужа дегтя (запрет движения и уязвимость к огню)
	TAR_TRAIL,          # Пермобафф героя: атаки связывают врагов дегтем
	PAIN_NUMB,          # Болевой шок / Анестезия (полный иммунитет к дебаффам)
	PHOSPHOR_BURN,      # Фосфорный ожог (снижает максимальное ХП цели за ход)
	PHOSPHOR_TRAIL,     # Пермобафф героя: атаки заставляют цели светиться (нельзя уклониться)
}

enum DamageType {
	PHYSIC,    # Физический
	FIRE,      # Огненный
	EXPLOSION, # Взрыв
	ACID,      # Кислота
	TAR,       # Урон от удушения смолой
	CHEMICAL,  # Химический ожог фосфора
}

var database: Dictionary = {
	# =========================================================================
	#                          ВОЛШЕБНЫЕ РЕАГЕНТЫ (6 штук)
	# =========================================================================

	# 1. Пыльца пикси (Стоимость: 1)
	"Мобильность Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.PUSH, "power": 1 } ],
	"Мобильность Защиты": [ { "target": TargetType.ALLY, "type": EffectType.PUSH, "power": 1 } ],
	"Иллюзорность Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.CRIT } ],
	"Иллюзорность Защиты": [ { "type": EffectType.BUFF, "status": EffectStatus.INVULNERABLE } ],
	"Легкость Атаки": [ { "type": EffectType.DISCOUNT_NAVAROT, "value": 2 } ],
	"Легкость Защиты": [ { "type": EffectType.DISCOUNT_NAVAROT, "value": 2 } ],

	# 2. Слезы дриады (Стоимость: 1)
	"Вегетация Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.CORROSION, "power": 4, "duration": 3 } ],
	"Вегетация Защиты": [ { "target": TargetType.ALLY, "type": EffectType.BUFF, "status": EffectStatus.REGENERATION, "power": 4, "duration": 3 } ],
	"Одеревенение Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.ROOT, "duration": 2 } ],
	"Одеревенение Защиты": [ { "type": EffectType.BUFF, "status": EffectStatus.WOOD_ARMOR, "duration": 2 } ],
	"Цветение Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.BLIND, "duration": 1 } ],
	"Цветение Защиты": [ { "type": EffectType.CLEANSE } ],

	# 3. Роса зари (Стоимость: 0)
	"Чистота Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.CLEANSE } ],
	"Чистота Защиты": [ { "target": TargetType.ALLY, "type": EffectType.CLEANSE } ],
	"Темп Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.ROOT, "duration": 1 } ],
	"Темп Защиты": [ { "type": EffectType.DISCOUNT_NAVAROT, "value": 1 } ],
	"Свежесть Атаки": [ { "type": EffectType.REFUND_REAGENT } ],
	"Свежесть Защиты": [ { "type": EffectType.REFUND_REAGENT } ],

	# 4. Сок луноцвета (Стоимость: 2)
	"Резонанс Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.CRIT } ],
	"Резонанс Защиты": [ { "target": TargetType.ALLY, "type": EffectType.BUFF, "status": EffectStatus.INVISIBILITY, "duration": 1 } ],
	"Сияние Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.BLIND, "duration": 2 } ],
	"Сияние Защиты": [ { "type": EffectType.BUFF, "status": EffectStatus.INVULNERABLE, "duration": 1 } ],
	"Отблиск Атаки": [ { "type": EffectType.DAMAGE, "power": 6 } ],
	"Отблиск Защиты": [ { "type": EffectType.BUFF, "status": EffectStatus.ASH_CLOUD, "duration": 2 } ],

	# 5. Застывший туман (Стоимость: 2) | Фазовый сдвиг, изоляция от АоЕ, слабость
	"Эфир Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.PHASE_SHIFT, "duration": 1 } ], # Враг выпадает из реальности на ход
	"Эфир Защиты": [ { "target": TargetType.POSITION, "type": EffectType.ZONE, "status": EffectStatus.ISOLATION_ZONE, "duration": 2 } ], # Клетка полностью защищена от урона по площади
	"Изоляция Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.WEAKNESS, "duration": 2 } ], # Туман душит ярость врага
	"Изоляция Защиты": [
		{ "type": EffectType.SHIELD, "damage_reduce_percent": 0.25, "duration": 2 },
		{ "type": EffectType.COUNTER_ATTACK, "duration": 2, "apply_to_attacker": { "type": EffectType.DEBUFF, "status": EffectStatus.WEAKNESS, "duration": 1 } }
	],
	"Осадок Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.ROOT, "duration": 2 } ],
	"Осадок Защиты": [ { "target": TargetType.SELF, "type": EffectType.BUFF, "status": EffectStatus.INVULNERABLE, "duration": 1 } ], # Герой получает краткий щит-оболочку

	# 6. Радужная эссенция (Стоимость: 3) | Хаос, призма эффектов, безумие
	"Призма Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.CHAOS_INVERSION, "duration": 2 } ], # Превращает баффы врага в дебаффы
	"Призма Защиты": [ { "target": TargetType.ALLY, "type": EffectType.CLEANSE } ], # Полная очистка обузы от скверны
	"Спектр Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.RANDOM_MADNESS, "duration": 1 } ], # Враг бьет случайную цель из-за галлюцинаций
	"Спектр Защиты": [
		{ "type": EffectType.SHIELD, "damage_reduce_percent": 0.3, "duration": 2 },
		{ "type": EffectType.COUNTER_ATTACK, "duration": 2, "apply_to_attacker": { "type": EffectType.DEBUFF, "status": EffectStatus.CRIT } } # Враг открывается под криты при ударе
	],
	"Откат Атаки": [ { "type": EffectType.DAMAGE, "power": 8 } ], # Радужная вспышка
	"Откат Защиты": [ { "target": TargetType.SELF, "type": EffectType.DISCOUNT_NAVAROT, "value": 3 } ], # Дарует герою космическое озарение (скидка 3 энергии)


	# =========================================================================
	#                          ЗЕМНЫЕ РЕАГЕНТЫ (5 штук)
	# =========================================================================

	# 1. ПОРОХ (Стоимость: 3)
	"Детонация Атаки": [ { "target": TargetType.ALL_ENEMIES, "type": EffectType.DAMAGE, "damage": DamageType.EXPLOSION, "power": 10 } ],
	"Детонация Защиты": [ { "target": TargetType.POSITION, "type": EffectType.BARRIER, "status": EffectStatus.POWDER_BARRIER, "power": 20 } ],
	"Горение Атаки": [ { "type": EffectType.ZONE, "status": EffectStatus.BURNING_ZONE, "damage": DamageType.FIRE, "power": 5, "duration": 3 } ],
	"Горение Защиты": [
		{ "type": EffectType.SHIELD, "status": EffectStatus.POWDER_SHIELD, "damage_reduce_percent": 0.5, "duration": 1 },
		{ "type": EffectType.COUNTER_ATTACK, "duration": 1, "apply_to_attacker": { "type": EffectType.DEBUFF, "status": EffectStatus.GUNPOWDER_DEBUFF } }
	],
	"Ошеломление Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.STUN, "duration": 1 } ],
	"Ошеломление Защиты": [
		{ "type": EffectType.BUFF, "status": EffectStatus.ROOT, "duration": 1 },
		{ "target": TargetType.SELF, "type": EffectType.BUFF, "status": EffectStatus.GUNPOWDER_TRAIL, "duration": -1 }
	],

	# 2. СОЛЯНАЯ КИСЛОТА (Стоимость: 4)
	"Разъедание Атаки": [
		{ "target": TargetType.ENEMY, "type": EffectType.DAMAGE, "damage": DamageType.ACID, "power": 12 },
		{ "type": EffectType.DEBUFF, "status": EffectStatus.MELTED_ARMOR, "duration": 3 }
	],
	"Разъедание Защиты": [ { "target": TargetType.ALLY, "type": EffectType.CLEANSE } ],
	"Плавление Атаки": [ { "type": EffectType.ZONE, "status": EffectStatus.BURNING_ZONE, "damage": DamageType.ACID, "power": 4, "duration": 2 } ],
	"Плавление Защиты": [
		{ "type": EffectType.SHIELD, "damage_reduce_percent": 0.3, "duration": 2 },
		{ "type": EffectType.COUNTER_ATTACK, "duration": 2, "apply_to_attacker": { "type": EffectType.DEBUFF, "status": EffectStatus.MELTED_ARMOR } }
	],
	"Токсикоз Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.CORROSION, "power": 8, "duration": 4 } ],
	"Токсикоз Защиты": [ { "target": TargetType.SELF, "type": EffectType.BUFF, "status": EffectStatus.ACID_TRAIL, "duration": -1 } ],

	# 3. ГОРЮЧИЙ ДЕГОТЬ (Стоимость: 2)
	"Связывание Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.ROOT, "duration": 2 } ],
	"Связывание Защиты": [ { "target": TargetType.POSITION, "type": EffectType.ZONE, "status": EffectStatus.TAR_ZONE, "duration": 3 } ],
	"Вязкость Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.MELTED_ARMOR, "duration": 2 } ], 
	"Вязкость Защиты": [
		{ "type": EffectType.SHIELD, "damage_reduce_percent": 0.2, "duration": 2 },
		{ "type": EffectType.COUNTER_ATTACK, "duration": 2, "apply_to_attacker": { "type": EffectType.DEBUFF, "status": EffectStatus.ROOT, "duration": 1 } }
	],
	"Удушье Атаки": [ { "type": EffectType.DAMAGE, "damage": DamageType.TAR, "power": 4, "duration": 3 } ],
	"Удушье Защиты": [ { "target": TargetType.SELF, "type": EffectType.BUFF, "status": EffectStatus.TAR_TRAIL, "duration": -1 } ],

	# 4. ОЧИЩЕННЫЙ ЭФИР (Стоимость: 3)
	"Наркоз Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.STUN, "duration": 1 } ], 
	"Наркоз Защиты": [ { "target": TargetType.ALLY, "type": EffectType.BUFF, "status": EffectStatus.STUN, "duration": 2 } ], 
	"Испарение Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.BLIND, "duration": 2 } ],
	"Испарение Защиты": [ { "type": EffectType.BUFF, "status": EffectStatus.PAIN_NUMB, "duration": 2 } ],
	"Кома Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.STUN, "duration": 2 } ],
	"Кома Защиты": [ { "target": TargetType.SELF, "type": EffectType.BUFF, "status": EffectStatus.PAIN_NUMB, "duration": -1 } ],

	# 5. ФОСФОРНЫЙ КОНЦЕНТРАТ (Стоимость: 3)
	"Свечение Атаки": [ { "target": TargetType.ENEMY, "type": EffectType.DEBUFF, "status": EffectStatus.CRIT } ],
	"Свечение Защиты": [ { "target": TargetType.POSITION, "type": EffectType.ZONE, "status": EffectStatus.ASH_CLOUD, "duration": 2 } ], 
	"Самовозгорание Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.PHOSPHOR_BURN, "power": 3, "duration": 4, "damage": DamageType.CHEMICAL } ],
	"Самовозгорание Защиты": [
		{ "type": EffectType.SHIELD, "damage_reduce_percent": 0.4, "duration": 1 },
		{ "type": EffectType.COUNTER_ATTACK, "duration": 1, "apply_to_attacker": { "type": EffectType.DEBUFF, "status": EffectStatus.PHOSPHOR_BURN, "power": 2 } }
	],
	"Ослепление Атаки": [ { "type": EffectType.DEBUFF, "status": EffectStatus.BLIND, "duration": 2 } ],
	"Ослепление Защиты": [ { "target": TargetType.SELF, "type": EffectType.BUFF, "status": EffectStatus.PHOSPHOR_TRAIL, "duration": -1 } ]
}

func get_effect_data(tag_name: String) -> Array:
	if database.has(tag_name):
		return database[tag_name]
	else:
		print("ВНИМАНИЕ: Эффект с именем '", tag_name, "' не найден в глобальной базе данных!")
		return []
