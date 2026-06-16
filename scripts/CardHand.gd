extends HBoxContainer
# CardHand — displays cards, manages selection.

const CardScene := preload("res://scenes/ui/Card.tscn")

var _deck_manager: DeckManagerScript = null
var _card_nodes: Array = []
var _selected_card: Node = null

signal card_picked(card_data: CardData, card_node: Node)

func setup(deck_manager: DeckManagerScript) -> void:
	_deck_manager = deck_manager
	_deck_manager.hand_changed.connect(_refresh_hand)

func _refresh_hand() -> void:
	for c in _card_nodes:
		if is_instance_valid(c):
			c.queue_free()
	_card_nodes.clear()
	_selected_card = null

	for data in _deck_manager.hand:
		var card_node: PanelContainer = CardScene.instantiate()
		add_child(card_node)
		card_node.setup(data)
		card_node.card_selected.connect(_on_card_selected)
		_card_nodes.append(card_node)

func _on_card_selected(card_node: Node) -> void:
	for c in _card_nodes:
		if is_instance_valid(c):
			c.set_selected(c == card_node)
	_selected_card = card_node
	card_picked.emit(card_node.card_data, card_node)

func deselect_all() -> void:
	for c in _card_nodes:
		if is_instance_valid(c):
			c.set_selected(false)
	_selected_card = null

func remove_card_node(card_node: Node) -> void:
	_card_nodes.erase(card_node)
	if card_node == _selected_card:
		_selected_card = null
	if is_instance_valid(card_node):
		card_node.queue_free()
