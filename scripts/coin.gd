extends Area2D

@onready var game_manager = %GameManager
@onready var animations = $AnimationPlayer

func _on_body_entered(_body: Node2D) -> void:
	print("+1 coin!")
	game_manager.coins_collected += 1
	game_manager.update_text()
	animations.play("pickup")
