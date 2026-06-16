extends Node
# GridLogic — autoload singleton with square-grid math helpers.

const COLS      := 5
const ROWS      := 5
const CELL_SIZE := 96   # pixels per cell

# Player zone = left 2 columns, enemy zone = right 2 columns.
func is_player_zone(col: int) -> bool:
	return col <= 1

func is_enemy_zone(col: int) -> bool:
	return col >= 3

func is_valid(col: int, row: int) -> bool:
	return col >= 0 and col < COLS and row >= 0 and row < ROWS

# Top-left corner of a cell in Grid-local space.
func cell_to_world(col: int, row: int) -> Vector2:
	return Vector2(col * CELL_SIZE, row * CELL_SIZE)

# Cell centre in Grid-local space.
func cell_center(col: int, row: int) -> Vector2:
	return Vector2(col * CELL_SIZE + CELL_SIZE / 2, row * CELL_SIZE + CELL_SIZE / 2)
