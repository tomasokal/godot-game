# Turn-Based Battle Proof of Concept

## Overview
This is a turn-based card battle game where Player 1 and Player 2 compete by playing cards from their hands following specific rules.

## Game Rules

### Starting the Game
- Each player is dealt 5 cards
- A starting card is placed from the deck
- Player 1 goes first

### Playing Cards
- On your turn, you must play a card that matches EITHER:
  - **The suit** of the last played card, OR
  - **The rank** of the last played card
- Example: If last card is "Hearts 7", you can play:
  - Any Hearts card (Hearts 8, Hearts King, etc.)
  - Any 7 (Acorns 7, Bells 7, Leaves 7)

### Multi-Card Plays
- **You can play multiple cards at once!**
- All cards must have the **same rank**
- Example: If "Hearts 7" was played, you can play:
  - Hearts King + Acorns King + Bells King (all Kings)
  - This changes the suit to Bells (the last card played)
- Cards are played in the order you select them
- The **last card's suit** becomes the new active suit

### Special Card Effects
- **Ace (A)**: Skip opponent's turn! You get to play again immediately
- **7**: Opponent must draw 3 cards per 7 played
  - Play one 7 = opponent draws 3 cards
  - Play two 7s = opponent draws 6 cards
  - Play three 7s = opponent draws 9 cards!

### Drawing Cards
- If you cannot play any card, you must draw a card
- Press **SPACE** to skip your turn and draw a card
- Cards that cannot be played are dimmed/disabled

### Winning
- First player to play all their cards wins! 🎉

## Card Deck
- **32-card German deck**
- **Suits**: Acorns, Hearts, Bells, Leaves
- **Ranks**: 7, 8, 9, 10, Unter, Ober, King, Ace
- Each suit maps to a unit type:
  - Acorns → Swordsman
  - Hearts → Monk
  - Bells → Archer
  - Leaves → Pikeman

## Controls
- **Click a Card**: Select/deselect that card
  - Selected cards are raised and highlighted
  - Can only select cards with the same rank
- **ENTER**: Play all selected cards
- **SPACE**: Skip turn and draw a card
- **ESC**: Quit the game

## Visual Features
- Cards are color-coded by suit:
  - **Acorns** = Brown
  - **Hearts** = Red
  - **Bells** = Gold/Yellow
  - **Leaves** = Green
- **Selected cards** are raised and highlighted bright yellow
- Valid cards are highlighted (full opacity)
- Invalid cards are dimmed (50% opacity)
- Cards on opponent's turn are dimmed
- Game state displayed at top showing:
  - Current player's turn
  - Last played card
  - Cards remaining in deck

## Console Output
The game prints detailed debug information:
- When cards are drawn
- When cards are selected/deselected
- When cards are played (including multi-card plays)
- Why cards cannot be played
- Special card effects (Ace skip, 7 draw penalty)
- Suit changes from multi-card plays
- Current hand sizes
- Turn changes
- Win conditions
- Deck reshuffling

## Running the Game

1. Open the project in Godot
2. Press F5 or click the Play button
3. The main.tscn scene will run automatically
4. Click cards to play them or press SPACE to draw

## Deck Management
- When the deck runs out, the discard pile is automatically reshuffled
- The last played card stays in play, rest go back to deck
- Seamless gameplay without interruption

## Files Modified
- `scripts/main.gd` - Game initialization and input handling
- `scripts/BattleManager.gd` - Turn-based battle logic and rule enforcement
- `scripts/player.gd` - Player actions, card management, and UI updates
- `scripts/Card.gd` - Card display and properties
- `scripts/DeckManager.gd` - 32-card German deck generation
- `scenes/main.tscn` - UI layout with game state display
- `scenes/card.tscn` - Card button appearance
- `scenes/player_hand.tscn` - Hand container layout

## Debugging Features
- Full console logging of all game actions
- Visual feedback for valid/invalid plays
- Turn indicator in UI
- Deck count display
- Automatic rule enforcement

## Future Enhancements
- Add scoring system
- Implement special card abilities
- Add animations for card plays
- Sound effects
- AI opponent
- Multiple rounds/best of series
- Card effects based on unit types
