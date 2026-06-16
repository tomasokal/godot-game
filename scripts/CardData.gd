extends Resource
class_name CardData

enum CardType { UNIT, EFFECT }

@export var card_name: String = "Card"
@export var card_type: CardType = CardType.UNIT
@export var unit_type: String = ""   # "archer", "lancer", "warrior", or "" for effects
@export var cost: int = 1
@export var description: String = ""
@export var art_color: Color = Color.WHITE  # tint for the card art placeholder

static func make_archer_card() -> CardData:
	var c := CardData.new()
	c.card_name = "Archer"
	c.unit_type = "archer"
	c.cost = 1
	c.description = "Long-range attacker.\nRange 3, ATK 3, HP 8"
	c.art_color = Color(0.4, 0.7, 1.0)
	return c

static func make_lancer_card() -> CardData:
	var c := CardData.new()
	c.card_name = "Lancer"
	c.unit_type = "lancer"
	c.cost = 2
	c.description = "Fast melee unit.\nRange 1, ATK 4, HP 12, SPD 2"
	c.art_color = Color(1.0, 0.6, 0.2)
	return c

static func make_warrior_card() -> CardData:
	var c := CardData.new()
	c.card_name = "Warrior"
	c.unit_type = "warrior"
	c.cost = 2
	c.description = "Tanky frontliner.\nRange 1, ATK 3, HP 15"
	c.art_color = Color(0.9, 0.3, 0.3)
	return c

static func make_reinforce_card() -> CardData:
	var c := CardData.new()
	c.card_name = "Reinforce"
	c.card_type = CardType.EFFECT
	c.cost = 0
	c.description = "Draw 2 extra cards\nthis planning phase."
	c.art_color = Color(0.6, 1.0, 0.6)
	return c
