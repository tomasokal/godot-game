extends PanelContainer
# Card — click to select; Battle scene handles placement on next cell click.

var card_data: CardData = null
var _selected: bool = false

signal card_selected(card_node: Node)

@onready var _title: Label      = $VBox/Title
@onready var _art: ColorRect    = $VBox/Art
@onready var _desc: Label       = $VBox/Desc
@onready var _cost_label: Label = $VBox/Cost

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	if card_data:
		_refresh()

func setup(data: CardData) -> void:
	card_data = data
	if is_node_ready():
		_refresh()

func _refresh() -> void:
	_title.text = card_data.card_name
	_art.color = card_data.art_color
	_desc.text = card_data.description
	_cost_label.text = "Cost: %d" % card_data.cost

func set_selected(on: bool) -> void:
	_selected = on
	if on:
		modulate = Color(1.4, 1.4, 0.5)
		var s := StyleBoxFlat.new()
		s.bg_color = Color(0.2, 0.2, 0.05)
		s.border_color = Color(1.0, 0.9, 0.2)
		s.set_border_width_all(3)
		add_theme_stylebox_override("panel", s)
	else:
		modulate = Color.WHITE
		remove_theme_stylebox_override("panel")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_selected.emit(self)
		get_viewport().set_input_as_handled()
