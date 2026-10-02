extends Area2D

@export var powerup_type : POWERUPS
@export var powerup_count : int
@export var powerup_timer : float
@export var respawn_time : float
enum POWERUPS {NONE, WALL_JUMP, DOUBLE_JUMP, DASH}
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.region_enabled = true
	var add_x : int = 0
	if powerup_count > 0:
		add_x = 16
	elif powerup_timer > 0.1:
		add_x = 32
	var add_y : int = 0
	if powerup_type == POWERUPS.WALL_JUMP:
		add_y = 0
	elif powerup_type == POWERUPS.DOUBLE_JUMP:
		add_y = 16
	elif powerup_type == POWERUPS.DASH:
		add_y = 48
	sprite.region_rect = Rect2(add_x, add_y, 16, 16)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if powerup_type == POWERUPS.WALL_JUMP:
			body.wall_jump_enabled = true
			if powerup_count > 0 && body.wall_jump_count != -1:
				body.wall_jump_count =  max(body.wall_jump_count, powerup_count)
			elif powerup_timer > 0.1 && !(body.wall_jump_duration < -0.5):
				body.wall_jump_duration = max(body.wall_jump_duration, powerup_timer)
			else:
				body.wall_jump_count = -1
				body.wall_jump_duration = -1
		elif powerup_type == POWERUPS.DOUBLE_JUMP:
			body.double_jump_enabled = true
			if powerup_count > 0 && body.double_jump_count != -1:
				body.double_jump_count = max(body.double_jump_count, powerup_count)
			elif powerup_timer > 0.1 && !(body.double_jump_duration < -0.5):
				body.double_jump_duration = max(body.double_jump_duration, powerup_timer)
			else:
				body.double_jump_count = -1
				body.double_jump_duration = -1
		elif powerup_type == POWERUPS.DASH:
			body.dash_enabled = true
			if powerup_count > 0  && body.dash_count != -1:
				body.dash_count = max(body.dash_count, powerup_count)
			elif powerup_timer > 0.1 && !(body.dash_duration < -0.5):
				body.dash_duration = max(body.dash_duration, powerup_timer)
			else:
				body.dash_count = -1
				body.dash_duration = -1
		#Play collection animation & sound
		body.update_powerup_icons()
		#visible = false
		sprite.self_modulate.a = 0.25
		set_collision_mask_value(1, false)
		if respawn_time > 0.1:
			await get_tree().create_timer(respawn_time).timeout
			#visible = true
			sprite.self_modulate.a = 1
			set_collision_mask_value(1, true)
		else:
			queue_free()
