extends Node
# Scenarios — autoload singleton providing named debug presets.
# Square grid: player zone cols 0-1, enemy zone cols 3-4, rows 0-4.

func get_scenario(id: int) -> Array:
	match id:
		1: return _mirror_match()
		2: return _archer_swarm()
		3: return _boss_fight()
		_:
			push_warning("Scenario %d not found." % id)
			return []

func _mirror_match() -> Array:
	return [
		{ "faction": "player", "unit_type": "warrior", "col": 0, "row": 1 },
		{ "faction": "player", "unit_type": "archer",  "col": 1, "row": 2 },
		{ "faction": "player", "unit_type": "lancer",  "col": 0, "row": 3 },
		{ "faction": "enemy",  "unit_type": "warrior", "col": 4, "row": 1 },
		{ "faction": "enemy",  "unit_type": "archer",  "col": 3, "row": 2 },
		{ "faction": "enemy",  "unit_type": "lancer",  "col": 4, "row": 3 },
	]

func _archer_swarm() -> Array:
	return [
		{ "faction": "player", "unit_type": "warrior", "col": 0, "row": 2 },
		{ "faction": "enemy",  "unit_type": "archer",  "col": 4, "row": 0 },
		{ "faction": "enemy",  "unit_type": "archer",  "col": 4, "row": 1 },
		{ "faction": "enemy",  "unit_type": "archer",  "col": 4, "row": 2 },
		{ "faction": "enemy",  "unit_type": "archer",  "col": 4, "row": 3 },
		{ "faction": "enemy",  "unit_type": "archer",  "col": 4, "row": 4 },
	]

func _boss_fight() -> Array:
	return [
		{ "faction": "player", "unit_type": "archer",  "col": 0, "row": 0 },
		{ "faction": "player", "unit_type": "archer",  "col": 0, "row": 4 },
		{ "faction": "player", "unit_type": "lancer",  "col": 1, "row": 1 },
		{ "faction": "player", "unit_type": "lancer",  "col": 1, "row": 3 },
		{ "faction": "enemy",  "unit_type": "warrior", "col": 4, "row": 2 },
	]

func list() -> String:
	return "1: Mirror Match\n2: Archer Swarm\n3: Boss Fight"
