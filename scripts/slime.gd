extends Node2D
class_name Slime

@onready var leftRay = $RayCastLeft
@onready var rightRay = $RayCastRight
@onready var downleftRay = $RayCastDownLeft
@onready var downrightRay = $RayCastDownRight
@onready var sprite = $AnimatedSprite2D
var speed : float = 48
var direction : int = 1

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	if leftRay.is_colliding() || !downleftRay.is_colliding():
		direction = 1
		sprite.flip_h = false
	elif rightRay.is_colliding() || !downrightRay.is_colliding():
		direction = -1
		sprite.flip_h = true
