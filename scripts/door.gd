extends AnimatableBody2D

@export var logic_channel : int
@export var inverted : bool
@export var tile_height : int = 1
@export var tile_width : int = 1
var solid : bool
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

func _ready() -> void:
	visible = false
	signal_bus.broadcast_logic_update.connect(update_logic)
	tilemap_reference = get_parent().get_parent().get_node("TileMapLayer")
	@warning_ignore_start("narrowing_conversion")
	var map_coords : Vector2i = Vector2i(position.x / 16, position.y / 16)
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
			solid = active
			#set_collision_layer_value(7, active)
		else:
			solid = !active
			#set_collision_layer_value(7, !active)
		affect_overlapping_tiles()
		
func affect_overlapping_tiles() -> void:
	if !solid:
		for tile : Tile in overlapped_tile_list:
			if tile.atlas_coords == Vector2i(2, 0):# || tile.atlas_coords == Vector2i(2, 1):
				tilemap_reference.set_cell(tile.coords, tile.source_id, tile.atlas_coords + Vector2i(3, 0))
			else:
				tilemap_reference.erase_cell(tile.coords)
	else:
		for tile : Tile in overlapped_tile_list:
			tilemap_reference.set_cell(tile.coords, tile.source_id, tile.atlas_coords)
