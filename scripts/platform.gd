extends AnimatableBody2D

@onready var sprite : Sprite2D = $Sprite2D
@export var style : STYLES
enum STYLES {TUTORIAL, LEVEL_1, LEVEL_2, LEVEL_3}

func _ready() -> void:
	var atlas : AtlasTexture = sprite.texture
	if style == STYLES.TUTORIAL:
		atlas.region = Rect2(0, 0, 32, 14)
	elif style == STYLES.LEVEL_1:
		atlas.region = Rect2(32, 0, 32, 14)
	if style == STYLES.LEVEL_3:
		atlas.region = Rect2(0, 32, 32, 14)
