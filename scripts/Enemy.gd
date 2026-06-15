extends Node
var hand = []

func draw_hand(deck, count):
    for i in range(count):
        hand.append(deck.draw_card())

func choose_card(current_suit):
    for card in hand:
        if card["suit"] == current_suit:
            return card
    return null

func remove_card(card):
    hand.erase(card)

func hand_empty():
    return hand.is_empty()
