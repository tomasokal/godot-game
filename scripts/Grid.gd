extends Node2D
# Grid — 5×5 square grid. Handles cell creation, unit placement, and click detection.

const GridCellScene := preload("res://scenes/grid/GridCell.tscn")

# _cells[row][col] → GridCell node
var _cells: Array = []

signal cell_selected(col: int, row: int)

func _ready() -> void:
	_build_grid()

func _build_grid() -> void:
	_cells.resize(GridLogic.ROWS)
	for row in GridLogic.ROWS:
		_cells[row] = []
		_cells[row].resize(GridLogic.COLS)
		for col in GridLogic.COLS:
			var cell: Node2D = GridCellScene.instantiate()
			add_child(cell)
			cell.position = Vector2(col * GridLogic.CELL_SIZE, row * GridLogic.CELL_SIZE)
			cell.setup(col, row)
			_cells[row][col] = cell

# ── Input — math-based click + hover, no collision shapes needed ──────────────
func _input(event: InputEvent) -> void:
	var local_pos := to_local(get_viewport().get_mouse_position())
	var col := int(local_pos.x / GridLogic.CELL_SIZE)
	var row := int(local_pos.y / GridLogic.CELL_SIZE)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GridLogic.is_valid(col, row):
			cell_selected.emit(col, row)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion:
		for r in GridLogic.ROWS:
			for c in GridLogic.COLS:
				_cells[r][c].set_hover(r == row and c == col and GridLogic.is_valid(col, row))

# ── Public API ────────────────────────────────────────────────────────────────
func get_cell(col: int, row: int) -> Node2D:
	if not GridLogic.is_valid(col, row):
		return null
	return _cells[row][col]

func is_cell_free(col: int, row: int) -> bool:
	var cell := get_cell(col, row)
	return cell != null and not cell.is_occupied()

func place_unit(unit: Node, col: int, row: int) -> bool:
	if not is_cell_free(col, row):
		return false
	var cell := get_cell(col, row)
	cell.occupant = unit
	unit.grid_col = col
	unit.grid_row = row
	unit.position = GridLogic.cell_center(col, row)
	return true

func move_unit(unit: Node, to_col: int, to_row: int) -> void:
	var old_cell := get_cell(unit.grid_col, unit.grid_row)
	if old_cell:
		old_cell.occupant = null
	unit.grid_col = to_col
	unit.grid_row = to_row
	var new_cell := get_cell(to_col, to_row)
	if new_cell:
		new_cell.occupant = unit
	# Animate with tween
	var tween := unit.create_tween()
	tween.tween_property(unit, "position", GridLogic.cell_center(to_col, to_row), 0.25)

func remove_unit(unit: Node) -> void:
	var cell := get_cell(unit.grid_col, unit.grid_row)
	if cell:
		cell.occupant = null
	unit.queue_free()

func get_all_units() -> Array:
	var result: Array = []
	for row in GridLogic.ROWS:
		for col in GridLogic.COLS:
			if _cells[row][col].is_occupied():
				result.append(_cells[row][col].occupant)
	return result

func clear_all_units() -> void:
	for unit in get_all_units():
		remove_unit(unit)

func highlight_player_zone(on: bool) -> void:
	for row in GridLogic.ROWS:
		for col in GridLogic.COLS:
			if GridLogic.is_player_zone(col):
				_cells[row][col].set_zone_highlight(on)
