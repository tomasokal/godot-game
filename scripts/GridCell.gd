extends Node2D
# GridCell — drawn via _draw(), no Control layout system involved.

var grid_col: int = 0
var grid_row: int = 0
var occupant: Node = null

const SIZE := 96.0

var _base_color: Color = Color(0.2, 0.2, 0.26)
var _zone_highlight: bool = false
var _hover: bool = false

func setup(col: int, row: int) -> void:
	grid_col = col
	grid_row = row
	if GridLogic.is_player_zone(col):
		_base_color = Color(0.15, 0.25, 0.55)
	elif GridLogic.is_enemy_zone(col):
		_base_color = Color(0.55, 0.15, 0.15)
	else:
		_base_color = Color(0.20, 0.20, 0.26)
	queue_redraw()

func set_zone_highlight(on: bool) -> void:
	_zone_highlight = on
	queue_redraw()

func set_hover(on: bool) -> void:
	_hover = on
	queue_redraw()

func is_occupied() -> bool:
	return occupant != null

func _draw() -> void:
	var fill: Color
	if _hover:
		fill = Color(0.85, 0.85, 0.25)
	elif _zone_highlight:
		fill = _base_color.lightened(0.2)
	else:
		fill = _base_color
	draw_rect(Rect2(0, 0, SIZE, SIZE), fill)
	draw_rect(Rect2(0, 0, SIZE, SIZE), Color(0, 0, 0, 0.6), false, 1.5)
