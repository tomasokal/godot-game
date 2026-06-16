extends Node
class_name BattleManagerScript

signal battle_ended(winner: String)
signal turn_resolved(turn_number: int)

var _grid: Node = null
var _turn: int = 0

func setup(grid_node: Node) -> void:
	_grid = grid_node

func resolve_turn() -> void:
	_turn += 1
	var all_units: Array = _grid.get_all_units()

	# ── Move phase ────────────────────────────────────────────────────────────
	for unit in all_units:
		if unit.current_hp > 0:
			_try_move(unit)

	# ── Attack phase — re-fetch after moves ───────────────────────────────────
	all_units = _grid.get_all_units()
	for unit in all_units:
		if unit.current_hp > 0:
			_try_attack(unit, all_units)

	# ── Remove dead ───────────────────────────────────────────────────────────
	for unit in _grid.get_all_units():
		if unit.current_hp <= 0:
			_grid.remove_unit(unit)

	turn_resolved.emit(_turn)

	var remaining: Array = _grid.get_all_units()
	var players: Array = remaining.filter(func(u): return u.faction == "player")
	var enemies: Array = remaining.filter(func(u): return u.faction == "enemy")

	if players.is_empty() and enemies.is_empty():
		battle_ended.emit("draw")
	elif players.is_empty():
		battle_ended.emit("enemy")
	elif enemies.is_empty():
		battle_ended.emit("player")

# ── Movement: march toward enemy side; stop when same-row foe is in range ────
func _try_move(unit: Node) -> void:
	var all_units: Array = _grid.get_all_units()
	var foes: Array = all_units.filter(func(u): return u.faction != unit.faction and u.current_hp > 0)

	# Don't advance if a same-row enemy is already within attack range
	for foe in foes:
		if foe.grid_row == unit.grid_row:
			if abs(foe.grid_col - unit.grid_col) <= unit.data.attack_range:
				return

	# Step one column toward the enemy side
	var dir: int = 1 if unit.faction == "player" else -1
	var next_col: int = unit.grid_col + dir
	if GridLogic.is_valid(next_col, unit.grid_row) and _grid.is_cell_free(next_col, unit.grid_row):
		_grid.move_unit(unit, next_col, unit.grid_row)

# ── Attack: target nearest same-row foe within attack_range columns ───────────
func _try_attack(unit: Node, all_units: Array) -> void:
	if unit.current_hp <= 0:
		return
	var foes: Array = all_units.filter(func(u): return u.faction != unit.faction and u.current_hp > 0)

	var target: Node = null
	var best_dist: int = 9999
	for foe in foes:
		if foe.grid_row == unit.grid_row:
			var dist: int = abs(foe.grid_col - unit.grid_col)
			if dist <= unit.data.attack_range and dist < best_dist:
				best_dist = dist
				target = foe

	if target:
		target.take_damage(unit.data.attack)

func reset() -> void:
	_turn = 0
