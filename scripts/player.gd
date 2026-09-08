extends CharacterBody2D
class_name PlayerController


const SPEED = 130.0
const DASH_MODIFIER = 5
const JUMP_VELOCITY = -300.0
@onready var sprite = $AnimatedSprite2D
@onready var left_wall_ray = $LeftWallRay
@onready var right_wall_ray = $RightWallRay

@export var wall_jump_enabled : bool = true
var wall_jump_movement_timeout : bool = false
@export var double_jump_enabled : bool = true
var expended_double_jump : bool = false
@export var dash_enabled : bool = true
var air_dash_used : bool = false
var is_dashing : bool = false

var coyote_time : float


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
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
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction && !wall_jump_movement_timeout && !is_dashing:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0)
	elif !wall_jump_movement_timeout && !is_dashing:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction == 0:
		sprite.animation = "idle"
	else:
		sprite.animation = "run"
	if !is_on_floor():
		sprite.animation = "jump"
		
	

	move_and_slide()

func handle_jump() -> void:
	var jumped = false
	if is_on_floor() || coyote_time > 0.0:
		velocity.y = JUMP_VELOCITY
		jumped = true
		
	elif is_on_wall() && wall_jump_enabled && !jumped:
		var direction := Input.get_axis("move_left", "move_right")
		if direction == -1 && left_wall_ray.is_colliding():
			velocity.y = JUMP_VELOCITY
			velocity.x = JUMP_VELOCITY * -0.25
			wall_jump_movement_timeout = true
			jumped = true
			await get_tree().create_timer(0.25).timeout
			wall_jump_movement_timeout = false
		elif direction == 1 && right_wall_ray.is_colliding():
			velocity.y = JUMP_VELOCITY
			velocity.x = JUMP_VELOCITY * 0.25
			wall_jump_movement_timeout = true
			jumped = true
			await get_tree().create_timer(0.25).timeout
			wall_jump_movement_timeout = false
		
	if double_jump_enabled && !expended_double_jump && !jumped:
		velocity.y = JUMP_VELOCITY
		expended_double_jump = true
	
func handle_dash() -> void:
	if !dash_enabled:
		return
	var direction : int = 1
	if sprite.flip_h:
		direction = -1
		
	if is_on_floor() || coyote_time > 0.0:
		velocity.x = SPEED * DASH_MODIFIER * direction
		is_dashing = true
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	elif !air_dash_used:
		velocity.x = SPEED * DASH_MODIFIER * direction
		is_dashing = true
		air_dash_used = true
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
	
