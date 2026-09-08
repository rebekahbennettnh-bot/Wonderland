extends AnimatableBody2D

@export var initial_direction : Vector2i
@export var speed : float
var move_direction : int = 1


func _physics_process(delta: float) -> void:
	position += speed * initial_direction * move_direction * delta


func _on_area_2d_body_entered(_body: Node2D) -> void:
	move_direction *= -1
