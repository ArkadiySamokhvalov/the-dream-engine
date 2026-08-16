# ReagentData.gd
class_name ReagentData
extends Resource

@export var reagent_name: String = "Иллюзорная Пыльца"
@export var is_earth_type: bool = false
@export var base_mana_cost: int = 1

# Теги для текстовых квестов и событий (например: ["взрыв_завала", "поджог_ворот"])
@export var quest_tags: Array[String] = []

@export_group("1. ЗАТРАВКА")
@export var zatravka_name: String = "Мобильность"
@export var zatravka_attack_tag: String = "Мобильность Атаки"
@export var zatravka_defense_tag: String = "Мобильность Защиты"

@export_group("2. НАВАРОТ")
@export var navarot_name: String = "Иллюзорность"
@export var navarot_attack_tag: String = "Иллюзорность Атаки"
@export var navarot_defense_tag: String = "Иллюзорность Защиты"

@export_group("3. ПРИХОД")
@export var prihod_name: String = "Легкость"
@export var prihod_attack_tag: String = "Легкость Атаки"
@export var prihod_defense_tag: String = "Легкость Защиты"
