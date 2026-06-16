extends Node
class_name DeckManagerScript

var _full_deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

signal hand_changed

func build_default_deck() -> void:
	_full_deck.clear()
	# 3× each unit card, 2× reinforce
	for i in 3:
		_full_deck.append(CardData.make_archer_card())
		_full_deck.append(CardData.make_lancer_card())
		_full_deck.append(CardData.make_warrior_card())
	for i in 2:
		_full_deck.append(CardData.make_reinforce_card())
	_full_deck.shuffle()
	hand.clear()
	discard_pile.clear()

func draw(count: int = 3) -> void:
	for _i in count:
		if _full_deck.is_empty():
			_reshuffle()
		if _full_deck.is_empty():
			break
		hand.append(_full_deck.pop_back())
	hand_changed.emit()

func discard_card(card: CardData) -> void:
	hand.erase(card)
	discard_pile.append(card)
	hand_changed.emit()

func add_card_to_hand(card: CardData) -> void:
	hand.append(card)
	hand_changed.emit()

func _reshuffle() -> void:
	_full_deck = discard_pile.duplicate()
	_full_deck.shuffle()
	discard_pile.clear()

func reset() -> void:
	build_default_deck()
