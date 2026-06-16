extends Node2D

const UnitScene := preload("res://scenes/units/Unit.tscn")

@onready var _grid: Node2D          = $Grid
@onready var _card_hand: HBoxContainer = $UI/Bottom/CardHand
@onready var _phase_label: Label    = $UI/Top/PhaseLabel
@onready var _turn_label: Label     = $UI/Top/TurnLabel
@onready var _action_btn: Button    = $UI/Top/ActionButton
@onready var _log_label: Label      = $UI/Log/LogLabel
@onready var _debug_console: CanvasLayer = $DebugConsole

var _deck_manager: DeckManagerScript   = DeckManagerScript.new()
var _battle_manager: BattleManagerScript = BattleManagerScript.new()
var _pending_card: CardData = null
var _pending_card_node: Node = null
var _turn: int = 0
var _log_lines: PackedStringArray = PackedStringArray()

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_child(_deck_manager)
	add_child(_battle_manager)

	_battle_manager.setup(_grid)
	_battle_manager.battle_ended.connect(_on_battle_ended)
	_battle_manager.turn_resolved.connect(_on_turn_resolved)

	_card_hand.setup(_deck_manager)
	_card_hand.card_picked.connect(_on_card_picked)

	_grid.cell_selected.connect(_on_cell_selected)

	_deck_manager.build_default_deck()
	_spawn_default_enemies()
	_enter_planning_phase()
	_debug_console.setup(self)

# ── Phase management ──────────────────────────────────────────────────────────
func _enter_planning_phase() -> void:
	GameManager.set_phase(GameManager.Phase.PLANNING)
	_phase_label.text = "Phase: Planning"
	_action_btn.text = "Start Battle"
	_grid.highlight_player_zone(true)
	_deck_manager.draw(3)
	_log("Draw 3 cards. Place units in blue zone, then Start Battle.")

func _enter_battle_phase() -> void:
	GameManager.set_phase(GameManager.Phase.BATTLE)
	_phase_label.text = "Phase: Battle"
	_action_btn.text = "Next Turn"
	_grid.highlight_player_zone(false)
	_log("Battle started! Press Next Turn to advance.")

func _on_action_button_pressed() -> void:
	match GameManager.current_phase:
		GameManager.Phase.PLANNING:
			_enter_battle_phase()
		GameManager.Phase.BATTLE:
			_battle_manager.resolve_turn()

# ── Card placement ────────────────────────────────────────────────────────────
func _on_card_picked(card_data: CardData, card_node: Node) -> void:
	if GameManager.current_phase != GameManager.Phase.PLANNING:
		_card_hand.deselect_all()
		_log("Can only place units during Planning phase.")
		return
	if card_data.card_type == CardData.CardType.EFFECT:
		_apply_effect_card(card_data)
		_deck_manager.discard_card(card_data)
		_card_hand.remove_card_node(card_node)
		return
	_pending_card = card_data
	_pending_card_node = card_node
	_grid.highlight_player_zone(true)
	_log("Select a blue cell to place %s." % card_data.card_name)

func _on_cell_selected(col: int, row: int) -> void:
	if _pending_card == null:
		return
	if not GridLogic.is_player_zone(col):
		_log("Must place in the blue zone (left 2 columns).")
		return
	if not _grid.is_cell_free(col, row):
		_log("Cell %d,%d is occupied." % [col, row])
		return
	var unit := _spawn_unit(_pending_card.unit_type, "player", col, row)
	if unit:
		_card_hand.deselect_all()
		_deck_manager.discard_card(_pending_card)
		_card_hand.remove_card_node(_pending_card_node)
		_grid.highlight_player_zone(false)
		_log("Placed %s at col %d, row %d." % [_pending_card.card_name, col, row])
	_pending_card = null
	_pending_card_node = null

func _apply_effect_card(card_data: CardData) -> void:
	if card_data.card_name == "Reinforce":
		_deck_manager.draw(2)
		_log("Reinforce! Drew 2 extra cards.")

# ── Unit spawning ─────────────────────────────────────────────────────────────
func _spawn_unit(unit_type: String, faction: String, col: int, row: int) -> Node:
	var data := _make_unit_data(unit_type, faction)
	if data == null:
		_log("Unknown unit type: %s" % unit_type)
		return null
	var unit: Node2D = UnitScene.instantiate()
	_grid.add_child(unit)
	unit.init(data, faction)
	unit.died.connect(_on_unit_died)
	if not _grid.place_unit(unit, col, row):
		unit.queue_free()
		_log("Could not place %s at %d,%d." % [unit_type, col, row])
		return null
	return unit

func _make_unit_data(unit_type: String, faction: String) -> UnitData:
	var d: UnitData
	match unit_type.to_lower():
		"archer":  d = UnitData.make_archer()
		"lancer":  d = UnitData.make_lancer()
		"warrior": d = UnitData.make_warrior()
		_: return null

	# Try Idle, Guard, Run sprites in order
	var color_prefix := "Black" if faction == "player" else "Red"
	var sprite_name  := unit_type.capitalize()
	var try_suffixes := ["Idle", "Guard", "Run"]
	for suffix in try_suffixes:
		var path := "res://assets/Units/%s Units/%s/%s_%s.png" % [color_prefix, sprite_name, sprite_name, suffix]
		if ResourceLoader.exists(path):
			d.sprite_sheet = load(path)
			break

	d.faction = faction
	return d

func _spawn_default_enemies() -> void:
	_spawn_unit("warrior", "enemy", 3, 1)
	_spawn_unit("archer",  "enemy", 4, 2)
	_spawn_unit("lancer",  "enemy", 3, 3)

# ── Battle callbacks ──────────────────────────────────────────────────────────
func _on_turn_resolved(turn_num: int) -> void:
	_turn = turn_num
	_turn_label.text = "Turn: %d" % _turn
	_log("Turn %d resolved." % _turn)

func _on_battle_ended(winner: String) -> void:
	_log("Battle over — Winner: %s" % winner)
	await get_tree().create_timer(1.5).timeout
	GameManager.go_to_end_screen(winner)

func _on_unit_died(unit: Node) -> void:
	_log("%s [%s] defeated." % [unit.data.unit_name, unit.faction])

# ── Debug API (called by DebugConsole) ────────────────────────────────────────
func debug_spawn(unit_type: String, col: int, row: int, faction: String) -> String:
	var unit := _spawn_unit(unit_type, faction, col, row)
	if unit:
		return "Spawned %s [%s] at %d,%d" % [unit_type, faction, col, row]
	return "Failed to spawn %s at %d,%d" % [unit_type, col, row]

func debug_clear() -> String:
	_grid.clear_all_units()
	return "All units cleared."

func debug_set_phase(phase_name: String) -> String:
	match phase_name.to_lower():
		"planning": _enter_planning_phase()
		"battle":   _enter_battle_phase()
		_: return "Unknown phase: %s" % phase_name
	return "Phase set to %s." % phase_name

func debug_load_scenario(id: int) -> String:
	debug_clear()
	var entries: Array = ScenariosScript.get_scenario(id)
	if entries.is_empty():
		return "Scenario %d not found." % id
	for e in entries:
		_spawn_unit(e["unit_type"], e["faction"], e["col"], e["row"])
	_enter_battle_phase()
	return "Scenario %d loaded." % id

func debug_give_card(unit_type: String) -> String:
	var card: CardData
	match unit_type.to_lower():
		"archer":    card = CardData.make_archer_card()
		"lancer":    card = CardData.make_lancer_card()
		"warrior":   card = CardData.make_warrior_card()
		"reinforce": card = CardData.make_reinforce_card()
		_: return "Unknown card: %s" % unit_type
	_deck_manager.add_card_to_hand(card)
	return "Added %s card to hand." % unit_type

# ── Log ───────────────────────────────────────────────────────────────────────
func _log(msg: String) -> void:
	_log_lines.append(msg)
	if _log_lines.size() > 6:
		_log_lines.remove_at(0)
	_log_label.text = "\n".join(_log_lines)
