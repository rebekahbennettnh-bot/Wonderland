extends Node2D
class_name RootNode

var current_level : Node2D
var narrator_tracker : int

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
	await get_tree().process_frame
	current_level = level
	add_child(level)
	
func start_level_1() -> void:
	var level_1 = preload("res://scenes/Levels/level_1.tscn").instantiate()
	start_level(level_1)

func start_tutorial() -> void:
	var tutorial = preload("res://scenes/Levels/tutorial.tscn").instantiate()
	start_level(tutorial)
	
func start_test_plane() -> void:
	var test_plane = preload("res://scenes/Levels/test_plane.tscn").instantiate()
	start_level(test_plane)
