extends CharacterBody2D
class_name PlayerController


const SPEED = 130.0
const DASH_MODIFIER = 5
const JUMP_VELOCITY = -300.0
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var left_wall_ray : RayCast2D = $LeftWallRay
@onready var right_wall_ray : RayCast2D = $RightWallRay
@onready var powerup_icons : Array[TextureRect] = [$AbilitiesUI/AbilitiesRect/HBoxContainer/DoubleJumpIcon, $AbilitiesUI/AbilitiesRect/HBoxContainer/WallJumpIcon, $AbilitiesUI/AbilitiesRect/HBoxContainer/DashIcon]
@onready var ability_rect : NinePatchRect = $AbilitiesUI/AbilitiesRect

@export var wall_jump_enabled : bool = true
var wall_jump_movement_timeout : bool = false
var wall_jump_duration : float = -1
var wall_jump_count : int = -1
@export var double_jump_enabled : bool = true
var expended_double_jump : bool = false
var double_jump_duration : float = -1
var double_jump_count : int = -1
@export var dash_enabled : bool = true
var air_dash_used : bool = false
var is_dashing : bool = false
var dash_duration : float = -1
var dash_count : int = -1

var coyote_time : float
var movement_frozen : bool

func _ready() -> void:
	update_powerup_icons()
	
func _physics_process(delta: float) -> void:
	if movement_frozen:
		return
	
	set_collision_mask_value(3, !Input.is_action_pressed("move_down"))
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		if (direction == -1 && left_wall_ray.is_colliding()) || (direction == 1 && right_wall_ray.is_colliding()):
			if velocity.y > 50 && wall_jump_enabled:
				velocity.y = 75
		coyote_time -= delta
		if coyote_time < 0.0:
			coyote_time = 0.0
	else:
		expended_double_jump = false
		air_dash_used = false
		coyote_time = 0.1

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		handle_jump()
	
	if Input.is_action_just_pressed("dash"):
		handle_dash()
	
	if direction && !wall_jump_movement_timeout && !is_dashing:
		if velocity.x > direction * SPEED && direction > 0:
			velocity.x -= (velocity.x - SPEED) * 0.1 + 1
		elif velocity.x < direction * SPEED && direction < 0:
			velocity.x -= (velocity.x + SPEED) * 0.1 - 1
		else:
			velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0)
	elif !wall_jump_movement_timeout && !is_dashing:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
		
	if wall_jump_duration > 0:
		wall_jump_duration -= delta
		if wall_jump_duration <= 0:
			wall_jump_duration = -1
			wall_jump_enabled = false
		update_powerup_icons()
	if double_jump_duration > 0:
		double_jump_duration -= delta
		if double_jump_duration <= 0:
			double_jump_duration = -1
			double_jump_enabled = false
		update_powerup_icons()
	if dash_duration > 0:
		dash_duration -= delta
		if dash_duration <= 0:
			dash_duration = -1
			dash_enabled = false
		update_powerup_icons()
	
	
	if is_on_floor() && abs(velocity.y) < 1:
		if direction == 0:
			sprite.animation = "idle"
		else:
			sprite.animation = "run"
		if !(sprite.is_playing()):
			sprite.play()
	elif !(sprite.animation == "start_jump" && sprite.is_playing()):
			sprite.animation = "jump"
	


func handle_jump() -> void:
	var jumped = false
	if is_on_floor() || coyote_time > 0.0:
		velocity.y = JUMP_VELOCITY
		jumped = true
		sprite.play("start_jump")
		
	elif is_on_wall() && wall_jump_enabled && !jumped:
		var direction := Input.get_axis("move_left", "move_right")
		if direction == -1 && left_wall_ray.is_colliding():
			if wall_jump_count > 0:
				wall_jump_count -= 1
				if wall_jump_count == 0:
					wall_jump_enabled = false
				update_powerup_icons()
			velocity.y = JUMP_VELOCITY
			velocity.x = JUMP_VELOCITY * -0.25
			wall_jump_movement_timeout = true
			jumped = true
			await get_tree().create_timer(0.25).timeout
			wall_jump_movement_timeout = false
		elif direction == 1 && right_wall_ray.is_colliding():
			if wall_jump_count > 0:
				wall_jump_count -= 1
				if wall_jump_count == 0:
					wall_jump_enabled = false
				update_powerup_icons()
			velocity.y = JUMP_VELOCITY
			velocity.x = JUMP_VELOCITY * 0.25
			wall_jump_movement_timeout = true
			jumped = true
			await get_tree().create_timer(0.25).timeout
			wall_jump_movement_timeout = false
		
	if double_jump_enabled && !expended_double_jump && !jumped:
		if double_jump_count > 0:
				double_jump_count -= 1
				if double_jump_count == 0:
					double_jump_enabled = false
				update_powerup_icons()
		velocity.y = JUMP_VELOCITY
		expended_double_jump = true
		sprite.play("start_jump")
	
func handle_dash() -> void:
	if !dash_enabled:
		return
	var direction : int = 1
	if sprite.flip_h:
		direction = -1
		
	if is_on_floor() || coyote_time > 0.0:
		if dash_count > 0:
			dash_count -= 1
			update_powerup_icons()
		velocity.x = SPEED * DASH_MODIFIER * direction
		is_dashing = true
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	elif !air_dash_used:
		if dash_count > 0:
			dash_count -= 1
			update_powerup_icons()
		velocity.x = SPEED * DASH_MODIFIER * direction
		is_dashing = true
		air_dash_used = true
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	
func update_powerup_icons() -> void:
	powerup_icons[0].visible = double_jump_enabled
	powerup_icons[1].visible = wall_jump_enabled
	powerup_icons[2].visible = dash_enabled
	ability_rect.visible = (double_jump_enabled || wall_jump_enabled || dash_enabled)
	if double_jump_duration > 0:
		powerup_icons[0].get_child(0).visible = true
		powerup_icons[0].get_child(1).visible = true
		powerup_icons[0].get_child(1).text = str(int(double_jump_duration))
	else:
		powerup_icons[0].get_child(0).visible = false
		powerup_icons[0].get_child(1).visible = false
	if wall_jump_duration > 0:
		powerup_icons[1].get_child(0).visible = true
		powerup_icons[1].get_child(1).visible = true
		powerup_icons[0].get_child(1).text = str(int(wall_jump_duration))
	else:
		powerup_icons[1].get_child(0).visible = false
		powerup_icons[1].get_child(1).visible = false
	if dash_duration > 0:
		powerup_icons[2].get_child(0).visible = true
		powerup_icons[2].get_child(1).visible = true
		powerup_icons[0].get_child(1).text = str(int(dash_duration))
	else:
		powerup_icons[2].get_child(0).visible = false
		powerup_icons[2].get_child(1).visible = false
	if double_jump_count > 0:
		powerup_icons[0].get_child(1).visible = true
		powerup_icons[0].get_child(1).text = str(double_jump_count)
	if wall_jump_count > 0:
		powerup_icons[1].get_child(1).visible = true
		powerup_icons[1].get_child(1).text = str(wall_jump_count)
	if dash_count > 0:
		powerup_icons[2].get_child(1).visible = true
		powerup_icons[2].get_child(1).text = str(dash_count)
	
