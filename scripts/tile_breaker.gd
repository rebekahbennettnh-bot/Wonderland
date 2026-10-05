extends Area2D

@export var max_hp : int = 2
@export var logic_channel : int
@export var inverted : bool
@export var tile_height : int = 2
@export var tile_width : int = 2
var hp : int
var jumped_on_timeout : bool
var tilemap_reference : TileMapLayer
var overlapped_tile_list : Array[Tile]
class Tile:
	var coords : Vector2i
	var atlas_coords : Vector2i
	var source_id : int
	func _init(p_coords : Vector2i, p_atlas_coords : Vector2i, p_source_id : int):
		coords = p_coords
		atlas_coords = p_atlas_coords
		source_id = p_source_id

@onready var signal_bus : SignalBus = %SignalBus
@onready var sound : AudioStreamPlayer = $"630594VinniRBoneBreak5"
@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var dash_collider : CollisionShape2D = $DashCollider/CollisionShape2D

func _ready() -> void:
	hp = max_hp
	var shape : RectangleShape2D = collider.shape
	shape.size.x = 16*tile_width
	var dash_shape : RectangleShape2D = dash_collider.shape
	dash_shape.size = Vector2((16*tile_width) + 6, 16*tile_height)
	visible = false
	signal_bus.broadcast_logic_update.connect(update_logic)
	tilemap_reference = get_parent().get_parent().get_node("TileMapLayer")
	@warning_ignore_start("narrowing_conversion")
	var map_coords : Vector2i = Vector2i(((position.x-(8*(tile_width-1))) / 16), (position.y-8) / 16)
	@warning_ignore_restore("narrowing_conversion")
	if position.x < 0:
		map_coords.x -= 1
	if position.y < 0:
		map_coords.y -= 1
	for x : int in tile_width:
		for y : int in tile_height:
			overlapped_tile_list.append(Tile.new(Vector2i(map_coords.x + x, map_coords.y + y), tilemap_reference.get_cell_atlas_coords(Vector2i(map_coords.x + x, map_coords.y + y)), tilemap_reference.get_cell_source_id(Vector2i(map_coords.x + x, map_coords.y + y))))
	update_logic(logic_channel, false)

func update_logic(channel : int, active : bool) -> void:
	if channel == logic_channel:
		if inverted:
			if active:
				hp = 0
				affect_overlapping_tiles()
			else:
				hp = max_hp
				affect_overlapping_tiles()
		else:
			if active:
				hp = max_hp
				affect_overlapping_tiles()
			else:
				hp = 0
				affect_overlapping_tiles()
		affect_overlapping_tiles()
		
func affect_overlapping_tiles() -> void:
	if hp <= 0:
		for tile : Tile in overlapped_tile_list:
			tilemap_reference.erase_cell(tile.coords)
	elif hp == 1:
		for tile : Tile in overlapped_tile_list:
			if tile.atlas_coords == Vector2i(2, 1):
				tilemap_reference.set_cell(tile.coords, tile.source_id, tile.atlas_coords + Vector2i(3, 0))
	elif hp >= 2:
		for tile : Tile in overlapped_tile_list:
			tilemap_reference.set_cell(tile.coords, tile.source_id, tile.atlas_coords)

func get_jumped_on() -> void:
	if !jumped_on_timeout && hp > 0:
		hp -= 1
		sound.pitch_scale = randf_range(0.75, 1.25)
		sound.play()
		affect_overlapping_tiles()
		jumped_on_timeout = true
		await get_tree().create_timer(0.5).timeout
		jumped_on_timeout = false


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if body.old_y > 0:
			get_jumped_on()

func _on_dash_collider_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if body.is_dashing:
			get_jumped_on()
