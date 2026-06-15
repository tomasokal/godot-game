extends Node

signal suit_changed(new_suit: String)

var deck_manager
var player1
var player2
var current_player_index = 0  # 0 = player1, 1 = player2
var last_played_card = null  # Track the last played card
var discard_pile: Array = []
var game_state_label

func _ready():
	player1 = get_node("/root/Main/Player1")
	player2 = get_node("/root/Main/Player2")
	game_state_label = get_node("/root/Main/UI/VBoxContainer/GameState")

func start_battle(deck_manager_ref):
	deck_manager = deck_manager_ref
	print("\n=== Battle Started! ===")
	print("Drawing 5 cards for each player...")
	
	# Draw 5 cards for each player
	for i in range(5):
		player1.draw_card(deck_manager.draw_card())
		player2.draw_card(deck_manager.draw_card())
	
	print("Player 1 hand size: %d" % player1.hand.size())
	print("Player 2 hand size: %d" % player2.hand.size())
	
	# Play the first card from the deck as the starting card
	last_played_card = deck_manager.draw_card()
	if last_played_card:
		discard_pile.append(last_played_card)
		print("\nStarting card: %s %s" % [last_played_card["suit"], last_played_card["rank"]])
		suit_changed.emit(last_played_card["suit"])
	
	# Set player 1 as active
	set_active_player(0)
	update_ui()

func update_ui():
	if game_state_label:
		var current_player_name = "Player 1" if current_player_index == 0 else "Player 2"
		var last_card_text = "None"
		if last_played_card:
			last_card_text = "%s %s" % [last_played_card["suit"], last_played_card["rank"]]
		
		game_state_label.text = "Current Turn: %s | Last Played: %s | Deck: %d cards" % \
			[current_player_name, last_card_text, deck_manager.deck.size()]
	
	# Update card states for both players
	player1.update_card_states()
	player2.update_card_states()

func set_active_player(player_index: int):
	current_player_index = player_index
	player1.is_turn = (player_index == 0)
	player2.is_turn = (player_index == 1)
	
	var current_player_name = "Player 1" if player_index == 0 else "Player 2"
	print("\n--- %s's Turn ---" % current_player_name)
	if last_played_card:
		print("Must match: %s OR %s" % [last_played_card["suit"], last_played_card["rank"]])
	
	# Check if player can play
	var current_player = get_current_player()
	if not can_play_any_card(current_player):
		print("%s has no playable cards! Must draw." % current_player_name)

func get_current_player() -> Node:
	return player1 if current_player_index == 0 else player2

func can_play_card(card_data) -> bool:
	if last_played_card == null:
		return true  # First card can be anything
	
	# Can play if suit OR rank matches
	return (card_data["suit"] == last_played_card["suit"] or 
			card_data["rank"] == last_played_card["rank"])

func can_play_any_card(player: Node) -> bool:
	for card_data in player.hand:
		if can_play_card(card_data):
			return true
	return false

func play_cards(player: Node, cards_data: Array, cards_buttons: Array):
	"""Play multiple cards at once (must all be same rank)"""
	var player_name = "Player 1" if player == player1 else "Player 2"
	
	# Check if it's this player's turn
	if not player.is_turn:
		print("%s: Not your turn!" % player_name)
		return false
	
	if cards_data.is_empty():
		print("No cards to play!")
		return false
	
	# Check if first card can be played
	var first_card = cards_data[0]
	if not can_play_card(first_card):
		print("%s: Cannot play %s %s - must match suit (%s) or rank (%s)!" % 
			  [player_name, first_card["suit"], first_card["rank"], 
			   last_played_card["suit"], last_played_card["rank"]])
		return false
	
	# Verify all cards have the same rank
	var rank = first_card["rank"]
	for card_data in cards_data:
		if card_data["rank"] != rank:
			print("All cards must have the same rank!")
			return false
	
	# Play all cards
	print("\n%s played %d cards:" % [player_name, cards_data.size()])
	for i in range(cards_data.size()):
		var card_data = cards_data[i]
		var card_button = cards_buttons[i]
		
		print("  - %s %s (%s)" % [card_data["suit"], card_data["rank"], card_data["unit_type"]])
		
		# Update game state
		discard_pile.append(card_data)
		player.hand.erase(card_data)
		card_button.queue_free()
	
	# The last card played determines the new suit
	last_played_card = cards_data[-1]
	print("New active suit: %s" % last_played_card["suit"])
	suit_changed.emit(last_played_card["suit"])
	print("%s has %d cards remaining" % [player_name, player.hand.size()])
	
	# Check for win condition
	if player.hand.is_empty():
		print("\n🎉 %s WINS! 🎉" % player_name)
		print("Game Over!")
		if game_state_label:
			game_state_label.text = "🎉 %s WINS! 🎉" % player_name
		return true
	
	# Apply special card effects
	apply_card_effects(player, cards_data)
	
	update_ui()
	return true

func apply_card_effects(player: Node, cards_data: Array):
	"""Apply special effects based on card ranks"""
	var opponent = player2 if player == player1 else player1
	var opponent_name = "Player 2" if player == player1 else "Player 1"
	var rank = cards_data[0]["rank"]
	
	match rank:
		"Ace":
			# Skip opponent's turn
			print("🃏 Ace effect: %s's turn is skipped!" % opponent_name)
			# Don't change turn, stay with current player
			return
		
		"7":
			# Opponent draws 3 cards per 7 played
			var total_draws = cards_data.size() * 3
			print("🎴 7 effect: %s must draw %d cards!" % [opponent_name, total_draws])
			opponent.draw_multiple_cards(total_draws)
			# Then switch turn normally
			next_turn()
		
		_:
			# No special effect, switch turn normally
			next_turn()

func play_card(player: Node, card_data, card_button):
	"""Legacy single card play - redirect to multi-card system"""
	play_cards(player, [card_data], [card_button])

func skip_turn():
	var current_player = get_current_player()
	var player_name = "Player 1" if current_player_index == 0 else "Player 2"
	
	if not current_player.is_turn:
		print("Not the active player's turn!")
		return
	
	print("%s drew a card" % player_name)
	var new_card = deck_manager.draw_card()
	
	if new_card:
		current_player.draw_card(new_card)
		print("Drew: %s %s" % [new_card["suit"], new_card["rank"]])
		print("%s now has %d cards" % [player_name, current_player.hand.size()])
	else:
		print("Deck is empty! Reshuffling discard pile...")
		reshuffle_discard_pile()
		skip_turn()
		return
	
	# Switch to next player
	next_turn()
	update_ui()

func reshuffle_discard_pile():
	if discard_pile.size() <= 1:
		print("Warning: No cards to reshuffle!")
		return
	
	# Keep the last played card, reshuffle the rest
	var last_card = discard_pile.pop_back()
	for card in discard_pile:
		deck_manager.deck.append(card)
	deck_manager.shuffle_deck()
	discard_pile.clear()
	discard_pile.append(last_card)
	print("Reshuffled %d cards back into deck" % deck_manager.deck.size())

func next_turn():
	set_active_player(1 - current_player_index)
