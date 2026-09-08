extends Node2D

func _ready() -> void:
	var menu = preload("res://scenes/title_screen.tscn").instantiate()
	add_child(menu)

func reset_game() -> void:
	get_child(0).queue_free()
	var new_game = preload("res://scenes/game.tscn").instantiate()
	add_child(new_game)
