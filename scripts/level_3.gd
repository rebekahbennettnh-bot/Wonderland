extends Node2D
class_name Level3

@onready var camera : Camera2D = $Camera2D
@onready var player : PlayerController = $Player
@onready var tower_map : TileMapLayer = $TowerMap
var tower_floor : int = 0

func _ready() -> void:
	#generate_tower()
	camera.position = Vector2(0, 0)
	return

func generate_tower() -> void:
	var new_part : TileMapLayer = load("res://scenes/Levels/Tower Components/tower_part_1.tscn").instantiate()
	for tile : Vector2i in new_part.get_used_cells():
		tower_map.set_cell(Vector2i(0, tower_floor * -16) + tile, 1, Vector2i(1, 3))
	tower_map.set_cells_terrain_connect(tower_map.get_used_cells(), 0, 0)

func _physics_process(delta: float) -> void:
	if player.position.y < (16 * -16 * (tower_floor - 1)):
		tower_floor += 1
		generate_tower()
	#camera.position.y = player.position.y
	camera.position.y -= delta * 24
	if player.position.y - camera.position.y < -72:
		camera.position.y = player.position.y + 72
