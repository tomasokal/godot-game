extends Node

@export var max_hp: int = 20
var hp: int
var hand: Array = []
var active_suit: String = ""
var is_turn: bool = false
var selected_cards: Array = []  # Cards selected for multi-card play

var hand_ui

func _ready():
	hp = max_hp
	print("Player initialized: %s" % name)
	
	# Find the correct hand UI based on player name
	if name == "Player1":
		hand_ui = get_node("/root/Main/UI/VBoxContainer/Player1Section/PlayerHand/HBoxContainer")
	elif name == "Player2":
		hand_ui = get_node("/root/Main/UI/VBoxContainer/Player2Section/PlayerHand/HBoxContainer")
	
	if not hand_ui:
		print("ERROR: Could not find hand_ui for %s" % name)

func draw_card(card_data):
	if card_data == null:
		print("Warning: Tried to draw null card")
		return
	
	hand.append(card_data)
	
	# Create card instance
	var card_instance = preload("res://scenes/card.tscn").instantiate()
	card_instance.suit = card_data["suit"]
	card_instance.rank = card_data["rank"]
	card_instance.unit_type = card_data["unit_type"]
	
	# Connect the card's pressed signal to card selection
	card_instance.pressed.connect(_on_card_pressed.bind(card_data, card_instance))
	
	# Add to UI
	if hand_ui:
		hand_ui.add_child(card_instance)
		update_card_states()  # Update which cards can be played
	else:
		print("Warning: hand_ui not found for %s" % name)

func draw_multiple_cards(count: int):
	"""Draw multiple cards (for 7 penalty)"""
	for i in range(count):
		var battle = get_node("/root/Main/BattleManager")
		var card_data = battle.deck_manager.draw_card()
		if card_data:
			draw_card(card_data)
		else:
			print("Deck empty during multi-draw")
			battle.reshuffle_discard_pile()
			# Try again after reshuffle
			card_data = battle.deck_manager.draw_card()
			if card_data:
				draw_card(card_data)

func _on_card_pressed(card_data, card_button):
	if not is_turn:
		return
	
	# Check if this card is already selected
	var card_entry = {"data": card_data, "button": card_button}
	var index = -1
	for i in range(selected_cards.size()):
		if selected_cards[i]["data"] == card_data:
			index = i
			break
	
	if index >= 0:
		# Deselect
		selected_cards.remove_at(index)
		card_button.position.y = 0  # Reset position
		print("Deselected: %s %s" % [card_data["suit"], card_data["rank"]])
	else:
		# Check if we can add this card to selection
		if can_add_to_selection(card_data):
			selected_cards.append(card_entry)
			card_button.position.y = -20  # Raise selected card
			print("Selected: %s %s (Total: %d)" % [card_data["suit"], card_data["rank"], selected_cards.size()])
		else:
			print("Cannot add %s %s to current selection (must match rank)" % [card_data["suit"], card_data["rank"]])
	
	update_card_states()

func can_add_to_selection(card_data) -> bool:
	if selected_cards.is_empty():
		var battle = get_node("/root/Main/BattleManager")
		return battle.can_play_card(card_data)
	
	# All cards must share the same rank
	var first_rank = selected_cards[0].data["rank"]
	return card_data["rank"] == first_rank

func play_selected_cards():
	if selected_cards.is_empty():
		print("No cards selected!")
		return
	
	var battle = get_node("/root/Main/BattleManager")
	var cards_data = []
	var cards_buttons = []
	
	for entry in selected_cards:
		cards_data.append(entry["data"])
		cards_buttons.append(entry["button"])
	
	battle.play_cards(self, cards_data, cards_buttons)
	selected_cards.clear()
	
	# Update card states after playing
	if hand_ui:
		update_card_states()

func update_card_states():
	# Update which cards can be played based on current turn
	if not hand_ui:
		return
	
	for card_button in hand_ui.get_children():
		if card_button is Button:
			# Find the corresponding card data
			var matching_card = null
			for card_data in hand:
				if (card_data["suit"] == card_button.suit and 
					card_data["rank"] == card_button.rank):
					matching_card = card_data
					break
			
			if matching_card:
				# Check if card is selected
				var is_selected = false
				for entry in selected_cards:
					if entry["data"] == matching_card:
						is_selected = true
						break
				
				if is_turn:
					var can_add = can_add_to_selection(matching_card)
					card_button.disabled = not can_add
					
					if is_selected:
						card_button.modulate = Color(1.5, 1.5, 1.0)  # Bright yellow for selected
					elif can_add:
						var full = card_button.modulate
						full.a = 1.0
						card_button.modulate = full  # assign back to apply
					else:
						var dim = card_button.modulate
						dim.a = 0.5
						card_button.modulate = dim
				else:
					card_button.disabled = true
					var off = card_button.modulate
					off.a = 0.5
					card_button.modulate = off  # Dimmed when not our turn
					card_button.position.y = 0  # Reset position
