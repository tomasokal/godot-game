extends Node

var deck_manager
var battle_manager
var player1
var player2
var state_manager: Node

func _ready():
	deck_manager = get_node("DeckManager")
	battle_manager = get_node("BattleManager")
	player1 = get_node("Player1")
	player2 = get_node("Player2")
    
	# Ensure StateManager exists to react to suit changes (shader color)
	state_manager = StateManager.new()
	add_child(state_manager)
	
	print("=== TURN-BASED BATTLE POC ===")
	print("Rules:")
	print("- Match the suit OR rank of the last played card")
	print("- Click cards to select them (same rank only)")
	print("- Press ENTER to play selected cards")
	print("- Multi-card plays change the suit to the last card")
	print("- Ace: Skip opponent's turn")
	print("- 7: Opponent draws 3 cards (per 7 played)")
	print("- SPACE: Skip turn (draw card)")
	print("- ESC: Quit")
	print("==============================")
	
	# Start the battle
	battle_manager.start_battle(deck_manager)

func _input(event):
	# Check for specific keys to avoid conflicts
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			# ENTER key - Play selected cards
			var current_player = battle_manager.get_current_player()
			if current_player.selected_cards.size() > 0:
				print("\n--- Playing %d selected cards ---" % current_player.selected_cards.size())
				current_player.play_selected_cards()
			else:
				print("No cards selected! Click cards to select them first.")
		elif event.keycode == KEY_SPACE:
			# SPACE key - Skip turn and draw
			print("\n--- Skipping turn, drawing card ---")
			battle_manager.skip_turn()
		elif event.keycode == KEY_ESCAPE:
			# ESC key - Quit
			print("\nQuitting...")
			get_tree().quit()