extends Area2D
class_name TartPiece

@onready var sprite : Sprite2D = $Sprite2D
var piece_texture : int
var final_display : bool

func _ready() -> void:
	sprite.region_enabled = true
	if final_display:
		sprite.region_rect = Rect2(32, 0, 16, 16)
		set_collision_mask_value(1, false)
	else:
		var part_texture : Vector2i = Vector2i(0, 16)
		if piece_texture == 1:
			part_texture = Vector2i(16, 16)
		elif piece_texture == 2:
			part_texture = Vector2i(32, 16)
		elif piece_texture == 3:
			part_texture = Vector2i(0, 32)
		elif piece_texture == 4:
			part_texture = Vector2i(16, 32)
		sprite.region_rect = Rect2(part_texture.x, part_texture.y, 16, 16)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		#Play collection animation & sound
		var level_ref : Level3 = get_parent()
		level_ref.collect_tart_piece()
		visible = false
		set_collision_mask_value(1, false)
		queue_free()
