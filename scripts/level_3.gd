extends Node2D
class_name Level3

@onready var camera : Camera2D = $Camera2D
@onready var player : PlayerController = $Player
@onready var tower_map : TileMapLayer = $TowerMap
@onready var powerup_list : Node = $Powerups
var tower_floor : int = 0

func _ready() -> void:
	#generate_tower()
	camera.position = Vector2(0, 0)
	return

func generate_tower() -> void:
	var new_part : TileMapLayer
	if tower_floor % 3 == 2:
		var rand_section = randi_range(1, 1)
		new_part = load("res://scenes/Levels/Tower Components/tower_part_powerup_" + str(rand_section) + ".tscn").instantiate()
	else:
		var rand_section = randi_range(1, 4)
		new_part = load("res://scenes/Levels/Tower Components/tower_part_basic_" + str(rand_section) + ".tscn").instantiate()
	for tile : Vector2i in new_part.get_used_cells():
		if new_part.get_cell_source_id(tile) == 3:
			var powerup_style : Powerup.POWERUPS = Powerup.POWERUPS.DOUBLE_JUMP
			if new_part.get_cell_atlas_coords(tile) == Vector2i(2, 2):
				powerup_style = Powerup.POWERUPS.WALL_JUMP
			elif new_part.get_cell_atlas_coords(tile) == Vector2i(1, 3):
				powerup_style = Powerup.POWERUPS.DASH
			var new_powerup : Powerup = load("res://scenes/powerup.tscn").instantiate()
			new_powerup.powerup_count = -1
			new_powerup.powerup_timer = 5
			new_powerup.respawn_time = -1
			new_powerup.powerup_type = powerup_style
			powerup_list.add_child(new_powerup)
			new_powerup.position = 16*(Vector2i(0, tower_floor * -12) + tile) + Vector2i(8, 0)
		else:
			tower_map.set_cell(Vector2i(0, tower_floor * -12) + tile, new_part.get_cell_source_id(tile), new_part.get_cell_atlas_coords(tile))
	#tower_map.set_cells_terrain_connect(tower_map.get_used_cells(), 0, 0)

func _physics_process(delta: float) -> void:
	if player.position.y < (16 * -12 * (tower_floor - 1)):
		tower_floor += 1
		generate_tower()
	#camera.position.y = player.position.y
	camera.position.y -= delta * 12 #delta * 24
	if player.position.y - camera.position.y < -72:
		camera.position.y = player.position.y + 72
