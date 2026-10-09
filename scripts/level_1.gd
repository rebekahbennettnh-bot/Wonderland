extends Node2D
class_name Level1

@onready var narrator : NPC = $NPCs/Narrator
@onready var cat2 : NPC = $NPCs/CheshireCat2
@onready var player : PlayerController = $Player
@onready var camera : Camera2D = $Camera2D
@onready var signal_bus : SignalBus = $SignalBus
@onready var win_ding : AudioStreamPlayer = $"395807MageduBuzzerBoardgame01"
@onready var puzzle_objects : Node = $PuzzleObjects
var dialogue_state : int
var camera_following : bool = true
var zoom_target : Vector2 = Vector2(4, 4)
var logic_list : Array[bool] = [false, false, false, false, false, false, false, false, false]
var cheshire_alt : bool

func _ready() -> void:
	var root_ref : RootNode = get_tree().current_scene
	cheshire_alt = root_ref.cheshire_alt
	if !get_tree().current_scene.get_node("Level1Music").playing:
		var level_1_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level1Music")
		if level_1_music != null:
			level_1_music.play(17.0)
	cat2.dialogue_state = 4
	signal_bus.connect("broadcast_logic_update", adjust_logic_list)

func adjust_logic_list(channel : int, active : bool) -> void:
	if cheshire_alt:
		if channel >= 1 && channel <= 9:
			logic_list[(channel-1)] = active
			var all_done : bool = true
			for i : int in 9:
				all_done = all_done && logic_list[i]
			if all_done:
				cat2.dialogue_state = 8
				await get_tree().create_timer(0.5).timeout
				win_ding.play()
	elif channel == 10 && active:
		win_ding.play()

func face_complete() -> bool:
	var complete : bool = true
	for n : Node in puzzle_objects.get_children():
		if n is TileBreaker:
			if n.logic_channel >= 1 && n.logic_channel <= 9:
				if n.dont_break_to_win:
					complete = complete && (n.hp > 0)
				else:
					complete = complete && (n.hp == 0)
	return complete

func _process(_delta: float) -> void:
	if camera_following:
		camera.position = player.position
	if camera.zoom != zoom_target:
		zoom_lerp()
		
func zoom_lerp() -> void:
	camera.zoom = camera.zoom.lerp(zoom_target, 0.1)

func _on_interact_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if dialogue_state < 1:
			dialogue_state = 1
			#tutorial_npc.interact()
			narrator.textbox_ui.hide()
			var new_text : String = narrator.dialogue_tree()
			if new_text != "":
				narrator.display_dialogue(new_text)

func _on_camera_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		camera_following = false
		zoom_target = Vector2(2, 2)
		camera.position = Vector2(1568, -48)


func _on_camera_trigger_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		camera_following = true
		zoom_target = Vector2(4, 4)


func _on_anti_softlock_trigger_body_entered(body: Node2D) -> void:
	if !logic_list[3] && cheshire_alt:
		if body is PlayerController:
			body.double_jump_count = -1
			body.double_jump_duration = -1
			body.double_jump_enabled = true
			body.update_powerup_icons()


func _on_anti_softlock_trigger_body_exited(body: Node2D) -> void:
	if !logic_list[3] && cheshire_alt:
		if body is PlayerController:
			body.double_jump_count = 0
			body.double_jump_duration = 0
			body.double_jump_enabled = false
			body.update_powerup_icons()


func _on_anti_softlock_trigger_2_body_entered(body: Node2D) -> void:
	if !logic_list[5] && cheshire_alt:
		if body is PlayerController:
			body.double_jump_count = -1
			body.double_jump_duration = -1
			body.double_jump_enabled = true
			body.update_powerup_icons()


func _on_anti_softlock_trigger_2_body_exited(body: Node2D) -> void:
	if !logic_list[5] && cheshire_alt:
		if body is PlayerController:
			body.double_jump_count = 0
			body.double_jump_duration = 0
			body.double_jump_enabled = false
			body.update_powerup_icons()


func _on_anti_softlock_trigger_3_body_entered(body: Node2D) -> void:
	if logic_list[4] && logic_list[7] && cheshire_alt:
		if body is PlayerController:
			body.double_jump_count = -1
			body.double_jump_duration = -1
			body.double_jump_enabled = true
			body.update_powerup_icons()


func _on_anti_softlock_trigger_3_body_exited(body: Node2D) -> void:
	if logic_list[4] && logic_list[7] && cheshire_alt:
		if body is PlayerController:
			body.double_jump_count = 0
			body.double_jump_duration = 0
			body.double_jump_enabled = false
			body.update_powerup_icons()


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if get_tree().current_scene.get_node("Level1Music").playing:
			var level_1_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level1Music")
			if level_1_music != null:
				level_1_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_level_2()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("secret_win_button"):
		if get_tree().current_scene.get_node("Level1Music").playing:
			var level_1_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level1Music")
			if level_1_music != null:
				level_1_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_level_2()
