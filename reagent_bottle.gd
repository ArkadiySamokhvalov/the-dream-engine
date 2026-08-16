extends Panel

@export var reagent_data: ReagentData
var is_on_cooldown: bool = false

@onready var label: Label = $Label
@onready var combat_root = get_tree().current_scene

func _ready() -> void:
	if reagent_data:
		setup_bottle(reagent_data)

func setup_bottle(data: ReagentData) -> void:
	reagent_data = data
	
	# Выводим имя и стоимость маны прямо на карточку в патронташе
	label.text = reagent_data.reagent_name + " (" + str(reagent_data.base_mana_cost) + ")"
	
	if reagent_data.is_earth_type:
		self.modulate = Color(0.2, 0.8, 0.2) # Земля — зеленая
	else:
		self.modulate = Color(1.0, 0.9, 0.3) # Кристалл — желтый


# ВСТРОЕННАЯ ФУНКЦИЯ GODOT: Вызывается автоматически при наведении мыши.
# Она ОБЯЗАНА возвращать узел (Control), который мы хотим показать вместо текста.
func _make_custom_tooltip(_for_text: String) -> Object:
	if not reagent_data or not combat_root:
		return null
		
	# Загружаем нашу кастомную сцену продвинутой подсказки
	var tooltip_scene = load("res://advanced_tooltip.tscn")
	if not tooltip_scene:
		print("ОШИБКА: Файл advanced_tooltip.tscn не найден в res://")
		return null
		
	var tooltip_instance = tooltip_scene.instantiate()
	
	# Настраиваем тексты внутри свитка, передавая данные и текущий режим кнопки А/З
	tooltip_instance.setup_tooltip(reagent_data, combat_root.is_attack_mode)
	
	# Возвращаем готовый интерфейс плашки в движок
	return tooltip_instance

# Логика перетаскивания (остается прежней)
func _get_drag_data(_at_position: Vector2) -> Variant:
	if is_on_cooldown:
		return null
	var drag_preview = Panel.new()
	drag_preview.size = self.size
	drag_preview.modulate = self.modulate
	var preview_label = Label.new()
	preview_label.text = label.text
	preview_label.size = drag_preview.size
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	drag_preview.add_child(preview_label)
	set_drag_preview(drag_preview)
	return self

func set_cooldown(active: bool) -> void:
	is_on_cooldown = active
	if is_on_cooldown:
		self.modulate.a = 0.2
	else:
		self.modulate.a = 1.0
