extends Node2D
class_name RootNode

var current_level : Node2D
var narrator_tracker : int
var cheshire_alt : bool

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
	cheshire_alt = false
	var level_1 = preload("res://scenes/Levels/level_1.tscn").instantiate()
	start_level(level_1)
	
func start_level_2() -> void:
	var level_2 = preload("res://scenes/Levels/level_2.tscn").instantiate()
	start_level(level_2)
	
func start_level_3() -> void:
	var level_3 = preload("res://scenes/Levels/level_3.tscn").instantiate()
	start_level(level_3)
	
func start_level_1_hard() -> void:
	cheshire_alt = true
	var level_1_hard = preload("res://scenes/Levels/level_1_hard.tscn").instantiate()
	start_level(level_1_hard)

func start_tutorial() -> void:
	var tutorial = preload("res://scenes/Levels/tutorial.tscn").instantiate()
	start_level(tutorial)
	
func start_test_plane() -> void:
	var test_plane = preload("res://scenes/Levels/test_plane.tscn").instantiate()
	start_level(test_plane)
	
func start_menu() -> void:
	var menu = preload("res://scenes/title_screen.tscn").instantiate()
	for child in get_children():
		if child is AudioStreamPlayer:
			if child.playing:
				child.stop()
	start_level(menu)
