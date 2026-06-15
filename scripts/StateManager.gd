extends Node

class_name StateManager

@onready var banners := get_node_or_null("/root/Main/CanvasLayer/UIControl/Triptych/Banners")

func _ready():
    var battle = get_node_or_null("/root/Main/BattleManager")
    if battle and battle.has_signal("suit_changed"):
        battle.suit_changed.connect(_on_suit_changed)

func _on_suit_changed(suit: String) -> void:
    var color = _suit_to_color(suit)
    if banners and banners.material is ShaderMaterial:
        var mat: ShaderMaterial = banners.material
        mat.set_shader_parameter("tint_color", color)

func _suit_to_color(suit: String) -> Color:
    match suit:
        "Bells":
            return Color(1.0, 0.85, 0.3, 1.0) # yellow/gold
        "Hearts":
            return Color(1.0, 0.4, 0.4, 1.0) # red
        "Acorns":
            return Color(0.6, 0.4, 0.2, 1.0) # brown
        "Leaves":
            return Color(0.4, 0.8, 0.4, 1.0) # green
        _:
            return Color(1, 1, 1, 1)
