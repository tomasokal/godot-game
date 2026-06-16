extends Resource
class_name UnitData

@export var unit_name: String = "Unit"
@export var faction: String = "player"
@export var max_hp: int = 10
@export var attack: int = 2
@export var attack_range: int = 1   # max column distance to attack
@export var speed: int = 1
@export var sprite_sheet: Texture2D
@export var frame_size: Vector2i = Vector2i(48, 48)

static func make_archer() -> UnitData:
	var d := UnitData.new()
	d.unit_name = "Archer"
	d.max_hp = 8
	d.attack = 3
	d.attack_range = 3   # fires 3 columns ahead
	d.speed = 1
	return d

static func make_lancer() -> UnitData:
	var d := UnitData.new()
	d.unit_name = "Lancer"
	d.max_hp = 12
	d.attack = 4
	d.attack_range = 2   # pike hits 2 columns ahead
	d.speed = 1
	return d

static func make_warrior() -> UnitData:
	var d := UnitData.new()
	d.unit_name = "Warrior"
	d.max_hp = 15
	d.attack = 3
	d.attack_range = 1   # adjacent melee only
	d.speed = 1
	return d
