extends Node2D

var current_level : Node2D

func _ready() -> void:
	var menu = preload("res://scenes/title_screen.tscn").instantiate()
	current_level = menu
	add_child(menu)

func reset_game() -> void:
	var level_path = current_level.scene_file_path
	current_level.queue_free()
	current_level = null
	var new_game = load(level_path).instantiate()
	current_level = new_game
	add_child(new_game)
	
func start_level(level : Node2D) -> void:
	current_level.queue_free()
	current_level = level
	add_child(level)
	
