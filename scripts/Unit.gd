extends Node2D
class_name Unit

var data: UnitData = null
var faction: String = "player"   # "player" or "enemy"
var current_hp: int = 0
var grid_col: int = 0
var grid_row: int = 0

@onready var _sprite: Sprite2D     = $Sprite2D
@onready var _hp_bar_bg: ColorRect = $HPBarBG
@onready var _hp_bar: ColorRect    = $HPBar
@onready var _name_label: Label    = $NameLabel

signal died(unit: Node)

func _ready() -> void:
	if data:
		_apply_data()

func init(unit_data: UnitData, unit_faction: String) -> void:
	data = unit_data
	faction = unit_faction
	current_hp = data.max_hp
	if is_node_ready():
		_apply_data()

func _apply_data() -> void:
	current_hp = data.max_hp
	_name_label.text = data.unit_name

	# Auto-detect frames — sheets are a single row of square frames.
	# e.g. 1152×192 → 6 hframes of 192×192; 3840×320 → 12 hframes of 320×320.
	if data.sprite_sheet:
		_sprite.texture = data.sprite_sheet
		var tex_w: int = data.sprite_sheet.get_width()
		var tex_h: int = data.sprite_sheet.get_height()
		_sprite.hframes = max(1, tex_w / tex_h)
		_sprite.vframes = 1
		_sprite.frame = 0
		# Scale frame to fit ~80 px inside the 96 px cell
		var s := 80.0 / float(tex_h)
		_sprite.scale = Vector2(s, s)
	else:
		_sprite.texture = null

	# Enemy units face left (toward player side)
	_sprite.flip_h = (faction == "enemy")
	_sprite.modulate = Color.WHITE
	_update_hp_bar()

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	_update_hp_bar()
	if current_hp <= 0:
		died.emit(self)

func heal(amount: int) -> void:
	current_hp = min(data.max_hp, current_hp + amount)
	_update_hp_bar()

func _update_hp_bar() -> void:
	if not is_node_ready() or data == null:
		return
	var pct := float(current_hp) / float(data.max_hp)
	_hp_bar.size.x = _hp_bar_bg.size.x * pct
	_hp_bar.color = Color(0.1, 0.9, 0.1) if pct > 0.5 else (Color(0.9, 0.7, 0.1) if pct > 0.25 else Color(0.9, 0.1, 0.1))

func get_stats_text() -> String:
	return "%s  HP:%d/%d  ATK:%d  RNG:%d  SPD:%d" % [
		data.unit_name, current_hp, data.max_hp, data.attack, data.range, data.speed
	]
