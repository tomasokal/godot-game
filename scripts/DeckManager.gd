extends Node

var deck: Array = []

func _ready():
    generate_deck()
    shuffle_deck()

func generate_deck():
    var suits = ["Acorns", "Hearts", "Bells", "Leaves"]
    var ranks = ["7", "8", "9", "10", "Unter", "Ober", "King", "Ace"]
    
    for suit in suits:
        for rank in ranks:
            deck.append({
                "suit": suit,
                "rank": rank,
                "unit_type": get_unit_for_suit(suit)
            })

func shuffle_deck():
    deck.shuffle()

func get_unit_for_suit(suit: String) -> String:
    match suit:
        "Acorns": return "Swordsman"
        "Hearts": return "Monk"
        "Bells": return "Archer"
        "Leaves": return "Pikeman"
        _: return "Unknown"

func draw_card():
    if deck.is_empty():
        return null
    return deck.pop_back()
