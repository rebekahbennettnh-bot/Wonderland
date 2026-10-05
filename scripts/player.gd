extends CharacterBody2D
class_name PlayerController


const SPEED = 130.0
const DASH_MODIFIER = 5
const JUMP_VELOCITY = -315.0
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var left_wall_ray : RayCast2D = $LeftWallRay
@onready var right_wall_ray : RayCast2D = $RightWallRay
@onready var top_left_wall_ray : RayCast2D = $TopLeftWallRay
@onready var top_right_wall_ray : RayCast2D = $TopRightWallRay
@onready var powerup_icons : Array[TextureRect] = [$AbilitiesUI/AbilitiesRect/VBoxContainer/DoubleJumpIcon, $AbilitiesUI/AbilitiesRect/VBoxContainer/WallJumpIcon, $AbilitiesUI/AbilitiesRect/VBoxContainer/DashIcon]
@onready var ability_rect : NinePatchRect = $AbilitiesUI/AbilitiesRect

@export var wall_jump_enabled : bool = true
var wall_jump_movement_timeout : bool = false
var wall_jump_duration : float = 0
var wall_jump_count : int = 0
@export var double_jump_enabled : bool = true
var expended_double_jump : bool = false
var double_jump_duration : float = 0
var double_jump_count : int = 0
@export var dash_enabled : bool = true
var air_dash_used : bool = false
var is_dashing : bool = false
var dash_duration : float = 0
var dash_count : int = 0

var coyote_time : float
var movement_frozen : bool
var move_left_buffer : float
var move_right_buffer : float
var jump_buffer : float
var dash_buffer : float
var hangtime_active : bool
var gravity_modifier : float = 1.0

var old_y : float

func _ready() -> void:
	if wall_jump_enabled:
		wall_jump_count = -1
		wall_jump_duration = -1
	if double_jump_enabled:
		double_jump_count = -1
		double_jump_duration = -1
	if dash_enabled:
		dash_count = -1
		dash_duration = -1
	update_powerup_icons()
	
func _physics_process(delta: float) -> void:
	old_y = velocity.y
	if movement_frozen:
		return
	
	if (velocity.y < -1 && velocity.y > -20 && !hangtime_active):
		hangtime_active = true
		gravity_modifier = 0.5
	elif (velocity.y > 20 || velocity.y < -20) && hangtime_active:
		hangtime_active = false
		gravity_modifier = 1
	
	set_collision_mask_value(3, !Input.is_action_pressed("move_down"))
	
	if move_left_buffer > 0.0:
		move_left_buffer = max(0.0, move_left_buffer - delta)
	if move_right_buffer > 0.0:
		move_right_buffer = max(0.0, move_right_buffer - delta)
	if jump_buffer > 0.0:
		jump_buffer = max(0.0, jump_buffer - delta)
	if dash_buffer > 0.0:
		dash_buffer = max(0.0, dash_buffer - delta)
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction == -1:
		move_left_buffer = 0.15
	elif direction == 1:
		move_right_buffer = 0.15
	
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_modifier
		if (direction == -1 && (left_wall_ray.is_colliding() || top_left_wall_ray.is_colliding())) || (direction == 1 && (right_wall_ray.is_colliding() || top_right_wall_ray.is_colliding())):
			if velocity.y > 40 && wall_jump_enabled:
				velocity.y = 40
		coyote_time -= delta
		if coyote_time < 0.0:
			coyote_time = 0.0
	else:
		expended_double_jump = false
		air_dash_used = false
		coyote_time = 0.1

	# Handle jump.
	if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("move_up"):
		jump_buffer = 0.15
		handle_jump()
	elif jump_buffer > 0:
		handle_jump()
	
	if Input.is_action_just_pressed("dash"):
		dash_buffer = 0.15
		handle_dash()
	elif dash_buffer > 0:
		handle_dash()
	
	if direction && !is_dashing:
		sprite.flip_h = (direction < 0)
		if !wall_jump_movement_timeout:
			if velocity.x > direction * SPEED && direction > 0:
				velocity.x -= (velocity.x - SPEED) * 0.1 + 1
			elif velocity.x < direction * SPEED && direction < 0:
				velocity.x -= (velocity.x + SPEED) * 0.1 - 1
			else:
				velocity.x = direction * SPEED
	elif !wall_jump_movement_timeout && !is_dashing:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
		
	if wall_jump_duration > 0:
		wall_jump_duration -= delta
		if wall_jump_duration <= 0:
			wall_jump_duration = 0
			wall_jump_enabled = false
		update_powerup_icons()
	if double_jump_duration > 0:
		double_jump_duration -= delta
		if double_jump_duration <= 0:
			double_jump_duration = 0
			double_jump_enabled = false
		update_powerup_icons()
	if dash_duration > 0:
		dash_duration -= delta
		if dash_duration <= 0:
			dash_duration = 0
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
		if (direction == -1 || move_left_buffer) && (left_wall_ray.is_colliding() || top_left_wall_ray.is_colliding()):
			if wall_jump_count > 0:
				wall_jump_count -= 1
				if wall_jump_count == 0:
					wall_jump_enabled = false
				update_powerup_icons()
			velocity.y = JUMP_VELOCITY
			velocity.x = JUMP_VELOCITY * -0.25
			wall_jump_movement_timeout = true
			jumped = true
			wall_jump_timeout_timer()
		elif (direction == 1 || move_right_buffer) && (right_wall_ray.is_colliding() || top_right_wall_ray.is_colliding()):
			if wall_jump_count > 0:
				wall_jump_count -= 1
				if wall_jump_count == 0:
					wall_jump_enabled = false
				update_powerup_icons()
			velocity.y = JUMP_VELOCITY
			velocity.x = JUMP_VELOCITY * 0.25
			wall_jump_movement_timeout = true
			jumped = true
			wall_jump_timeout_timer()
		
	elif double_jump_enabled && !expended_double_jump && !jumped:
		if double_jump_count > 0:
				double_jump_count -= 1
				if double_jump_count == 0:
					double_jump_enabled = false
				update_powerup_icons()
		velocity.y = JUMP_VELOCITY
		expended_double_jump = true
		sprite.play("start_jump")
	
	if jumped:
		jump_buffer = 0
		
func wall_jump_timeout_timer() -> void:	
	await get_tree().create_timer(0.25).timeout
	wall_jump_movement_timeout = false

func handle_dash() -> void:
	if !dash_enabled:
		return
	var direction : int = 1
	if sprite.flip_h:
		direction = -1
		
	if is_on_floor() || coyote_time > 0.0:
		if dash_count > 0:
			dash_count -= 1
			if dash_count == 0:
				dash_enabled = false
			update_powerup_icons()
		velocity.x = SPEED * DASH_MODIFIER * direction
		is_dashing = true
		dash_buffer = 0
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	elif !air_dash_used:
		if dash_count > 0:
			dash_count -= 1
			if dash_count == 0:
				dash_enabled = false
			update_powerup_icons()
		velocity.x = SPEED * DASH_MODIFIER * direction
		is_dashing = true
		dash_buffer = 0
		air_dash_used = true
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	
func update_powerup_icons() -> void:
	powerup_icons[0].visible = double_jump_enabled
	powerup_icons[1].visible = wall_jump_enabled
	powerup_icons[2].visible = dash_enabled
	var box_size = int(double_jump_enabled) + int(wall_jump_enabled) + int(dash_enabled)
	ability_rect.visible = (box_size > 0)
	ability_rect.size.y = 8 + 28*box_size
	ability_rect.position.y = 226 - (28 * (box_size - 1))
	if double_jump_duration > 0:
		powerup_icons[0].get_child(0).visible = true
		powerup_icons[0].get_child(1).visible = true
		powerup_icons[0].get_child(1).text = str(int(double_jump_duration) + 1)
	else:
		powerup_icons[0].get_child(0).visible = false
		powerup_icons[0].get_child(1).visible = false
	if wall_jump_duration > 0:
		powerup_icons[1].get_child(0).visible = true
		powerup_icons[1].get_child(1).visible = true
		powerup_icons[1].get_child(1).text = str(int(wall_jump_duration) + 1)
	else:
		powerup_icons[1].get_child(0).visible = false
		powerup_icons[1].get_child(1).visible = false
	if dash_duration > 0:
		powerup_icons[2].get_child(0).visible = true
		powerup_icons[2].get_child(1).visible = true
		powerup_icons[2].get_child(1).text = str(int(dash_duration) + 1)
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
	
