extends Node2D
class_name Level2

@onready var narrator : NPC = $NPCs/Narrator
@onready var dormouse2 : NPC = $NPCs/Dormouse2
@onready var hatter : NPC = $NPCs/Hatter
@onready var player : PlayerController = $Player
@onready var camera : Camera2D = $Camera2D
@onready var signal_bus : SignalBus = $SignalBus
@onready var cake_sprite : Sprite2D = $Triggers/CakeTrigger/Sprite2D
@onready var eat_sound : AudioStreamPlayer = $"867040Dinoworld112EatSound"
@onready var grow_sound : AudioStreamPlayer = $"453333KylesMetalCrankGroanOgg"
@onready var exclamation : Sprite2D = $Decorations/Exclamation
@onready var powerup_list : Node = $Powerups
@onready var quizgiver : NPC = $NPCs/Quizgiver
var dialogue_state : int
var camera_following : bool = true
var zoom_target : Vector2 = Vector2(4, 4)
var player_in_party : bool
var hatter_looking : bool = true
var hatter_switch_countdown : float = 0.1
var question_active : bool
var hatter_rant_triggered : bool
var hatter_big : bool
var has_cake : bool
var sending_in_process : bool
var dormouse_sleep_timer : float = 15
var previous_question : int

func _ready() -> void:
	dormouse2.dialogue_state = 4
	if !get_tree().current_scene.get_node("Level2Music").playing:
		var level_2_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level2Music")
		if level_2_music != null:
			level_2_music.play(0.0)

func _process(delta: float) -> void:
	dormouse_sleep_timer -= delta
	if dormouse_sleep_timer <= 0:
		dormouse_sleep_timer = 0
		dormouse_sleep_timer = 10 + randi_range(2, 10)
		dormouse2.sprite.play("sleeping")
		dormouse2.portrait.play("sleeping")
	if camera_following:
		camera.position = player.position
	if camera.zoom != zoom_target:
		zoom_lerp()
	if !question_active:
		dormouse2.can_interact = true
	if hatter_switch_countdown > 0 && hatter_switch_countdown < 1 && !hatter_big && hatter_rant_triggered && !hatter_looking:
		exclamation.visible = true
	else:
		exclamation.visible = false
	if hatter_switch_countdown <= 0:
		hatter_switch()
	if !question_active && hatter_rant_triggered && !hatter_big:
		hatter_switch_countdown -= delta
	if hatter_looking && player_in_party && (player.velocity.length() > 1) && !hatter_big && hatter_rant_triggered:
		hatter_sendback()

func zoom_lerp() -> void:
	camera.zoom = camera.zoom.lerp(zoom_target, 0.1)
	
func hatter_sendback() -> void:
	if sending_in_process:
		return
	player_freeze_sendback()
	hatter.dialogue_state = 3
	hatter.interact()
	hatter.dialogue_state = 4
	
func player_freeze_sendback() -> void:
	if sending_in_process:
		return
	player.velocity = Vector2(0, 0)
	sending_in_process = true
	player.movement_frozen = true
	await get_tree().create_timer(1).timeout
	player.position = Vector2(784, -304)
	player.movement_frozen = false
	sending_in_process = false

func hatter_switch() -> void:
	hatter_looking = !hatter_looking
	if hatter_looking:
		if player_in_party:
			start_question()
		hatter.scale.x = 1
		hatter_switch_countdown = randf_range(3, 5)
	else:
		hatter.scale.x = -1
		hatter_switch_countdown = randf_range(5, 10)

func hatter_rant() -> void:
	player.movement_frozen = true
	await get_tree().create_timer(0.5).timeout
	hatter.interact()
	await get_tree().create_timer(5).timeout
	#hatter.interact()
	await get_tree().process_frame
	hatter.interact()
	await get_tree().create_timer(5).timeout
	#hatter.interact()
	await get_tree().process_frame
	hatter.interact()
	await get_tree().create_timer(4).timeout
	#hatter.interact()
	player.movement_frozen = false
	hatter_rant_triggered = true
	
func hatter_grow() -> void:
	hatter_big = true
	await get_tree().create_timer(2).timeout
	eat_sound.play()
	await get_tree().create_timer(0.5).timeout
	grow_sound.play()
	await get_tree().create_timer(0.25).timeout
	for i : int in 60:
		hatter.scale *= 1.03
		hatter.position.y = -496 - (16 * hatter.scale.y)
		await get_tree().process_frame
		
func start_question() -> void:
	dormouse2.can_interact = false
	question_active = true
	var rand : int = randi_range(1, 3) * 10
	while rand == previous_question:
		rand = randi_range(1, 3) * 10
	previous_question = rand
	hatter.dialogue_state = -1
	hatter.interact()
	hatter.interact()
	hatter.interact()
	hatter.dialogue_state = 4
	await get_tree().process_frame
	quizgiver.dialogue_state = rand
	player.movement_frozen = true
	quizgiver.interact()
	await get_tree().create_timer(5).timeout
	quizgiver.interact()

func give_powerup() -> void:
	var type : Powerup.POWERUPS
	var rand : int = randi_range(1, 3)
	if rand == 1:
		type = Powerup.POWERUPS.WALL_JUMP
	elif rand == 2:
		type = Powerup.POWERUPS.DOUBLE_JUMP
	else:
		type = Powerup.POWERUPS.DASH
	var new_powerup : Powerup = preload("res://scenes/powerup.tscn").instantiate()
	new_powerup.powerup_type = type
	new_powerup.powerup_count = 3
	new_powerup.powerup_timer = -1
	new_powerup.respawn_time = -1
	powerup_list.add_child(new_powerup)
	new_powerup.position = Vector2(928, -320)


func _on_party_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if !hatter_rant_triggered:
			hatter_rant()
		player_in_party = true
		camera_following = false
		zoom_target = Vector2(3, 3)
		camera.position = Vector2(920, -392)


func _on_party_trigger_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_in_party = false
		camera_following = true
		zoom_target = Vector2(4, 4)


func _on_escape_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if !hatter_big:
			hatter_sendback()


func _on_cake_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		has_cake = true
		cake_sprite.visible = false


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if get_tree().current_scene.get_node("Level2Music").playing:
			var level_2_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level2Music")
			if level_2_music != null:
				level_2_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_level_3()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("secret_win_button"):
		if get_tree().current_scene.get_node("Level2Music").playing:
			var level_2_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level2Music")
			if level_2_music != null:
				level_2_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_level_3()
