extends Area2D

@export var powerup_type : POWERUPS
enum POWERUPS {NONE, WALL_JUMP, DOUBLE_JUMP, DASH}

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if powerup_type == POWERUPS.WALL_JUMP:
			body.wall_jump_enabled = true
		elif powerup_type == POWERUPS.DOUBLE_JUMP:
			body.double_jump_enabled = true
		elif powerup_type == POWERUPS.DASH:
			body.dash_enabled = true
		#Play collection animation & sound
		visible = false
