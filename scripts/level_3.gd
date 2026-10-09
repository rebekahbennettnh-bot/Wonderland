extends Node2D
class_name Level3

@onready var camera : Camera2D = $Camera2D
@onready var player : PlayerController = $Player
@onready var tower_map : TileMapLayer = $TileMapLayer
@onready var background : TileMapLayer = $Background
@onready var powerup_list : Node = $Powerups
@onready var puzzle_objects : Node = $PuzzleObjects
@onready var tower_blocker : TileBreaker = $PuzzleObjects/TowerBlocker
@onready var platform_list : Node = $Platforms
@onready var signal_bus : SignalBus = %SignalBus
@onready var capture_texture : TextureRect = $Camera2D/CaptureTrigger/TextureRect
@onready var queen : NPC = $NPCs/Queen
@onready var elevator : Sprite2D = $Elevator
@onready var exit_trigger : Area2D = $Triggers/ExitTrigger
@onready var collect_sound : AudioStreamPlayer = $"529951BeetlemuseDingPenguinSnowGlobeGame"
@onready var complete_sound : AudioStreamPlayer = $"684796IainmccurdyDingAirFryer"
var tower_floor : int = 0
var tower_scrolling : bool
var camera_following : bool = true
var pieces_collected : int
var top_generated : bool
var top_y : int
var suits_animation_timer : float = 0.5
var tart_pity : int = 3
var elevator_active : bool
var top_reached : bool

func _ready() -> void:
	if !get_tree().current_scene.get_node("Level3Music").playing:
		var level_3_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level3Music")
		if level_3_music != null:
			level_3_music.play(0.0)
	#generate_tower()
	#camera.position = Vector2(0, 0)
	tower_floor += 1
	generate_tower()
	return

func generate_tower() -> void:
	if top_generated:
		return
	var new_part : TileMapLayer
	if tower_floor % 3 == 2:
		var rand_section = randi_range(1, 4)
		new_part = load("res://scenes/Levels/Tower Components/tower_part_powerup_" + str(rand_section) + ".tscn").instantiate()
	else:
		var rand_section = randi_range(1, 8)
		new_part = load("res://scenes/Levels/Tower Components/tower_part_basic_" + str(rand_section) + ".tscn").instantiate()
	for tile : Vector2i in new_part.get_used_cells():
		if new_part.get_cell_source_id(tile) == 3:
			if new_part.get_cell_atlas_coords(tile) == Vector2i(0, 1):
				var tart_check = randi_range(1, tart_pity)
				if tart_check == 1:
					tart_pity = 4
					var new_tart : TartPiece = load("res://scenes/tart_piece.tscn").instantiate()
					new_tart.piece_texture = pieces_collected
					add_child(new_tart)
					new_tart.position = 16*(Vector2i(0, tower_floor * -13) + tile) + Vector2i(8, 0)
				else:
					tart_pity -= 1
			else:
				var powerup_style : Powerup.POWERUPS = Powerup.POWERUPS.DOUBLE_JUMP
				if new_part.get_cell_atlas_coords(tile) == Vector2i(2, 2):
					powerup_style = Powerup.POWERUPS.WALL_JUMP
				elif new_part.get_cell_atlas_coords(tile) == Vector2i(1, 3):
					powerup_style = Powerup.POWERUPS.DASH
				var new_powerup : Powerup = load("res://scenes/powerup.tscn").instantiate()
				new_powerup.powerup_count = 3
				new_powerup.powerup_timer = -1
				new_powerup.respawn_time = -1
				new_powerup.powerup_type = powerup_style
				powerup_list.add_child(new_powerup)
				new_powerup.position = 16*(Vector2i(0, tower_floor * -13) + tile) + Vector2i(8, 0)
		else:
			tower_map.set_cell(Vector2i(0, tower_floor * -13) + tile, new_part.get_cell_source_id(tile), new_part.get_cell_atlas_coords(tile))
	generate_background()
		#tower_map.set_cells_terrain_connect(tower_map.get_used_cells(), 0, 0)

func generate_background() -> void:
	for x : int in 21:
		for y : int in 13:
			background.set_cell(Vector2i(x-8, y + (-13*tower_floor) - 6), 2, Vector2i(2+randi_range(0, 1), 3))

func _physics_process(delta: float) -> void:
	if tower_scrolling && player.position.y < (16 * -13 * (tower_floor - 1)) && !top_generated:
		tower_floor += 1
		generate_tower()
	#camera.position.y = player.position.y
	if !camera_following && tower_scrolling:
		capture_texture.visible = true
		suits_animation_timer -= delta
		if suits_animation_timer <= 0:
			suits_animation_timer = 0.5
			var atlas : AtlasTexture = capture_texture.texture
			atlas.region.position.y = int(atlas.region.position.y + 16) % 32
		if top_generated && camera.position.y < top_y-16:
			camera.position.y = top_y - 16
			top_reached = true
			tower_scrolling = false
		else:
			camera.position.y -= delta * 12 #delta * 24 #delta * 16
			if player.position.y - camera.position.y < -72:
				camera.position.y = player.position.y + 72
	else:
		capture_texture.visible = false
	if elevator_active:
		queen.position.y = lerp(queen.position.y, camera.position.y, 0.02)
		elevator.position.y = lerp(elevator.position.y, camera.position.y + 20, 0.02)

func _process(_delta : float) -> void:
	if camera_following:
		camera.position = player.position
		
func capture_player() -> void:
	top_generated = false
	top_y = 0
	camera.position = Vector2(0, 0)
	tower_scrolling = false
	player.position = Vector2(0, 72+24)
	player.dash_count = 0
	player.wall_jump_count = 0
	player.double_jump_count = 0
	player.dash_enabled = false
	player.wall_jump_enabled = false
	player.double_jump_enabled = false
	player.update_powerup_icons()
	await get_tree().create_timer(2).timeout
	for cell : Vector2i in tower_map.get_used_cells():
		if cell.y <= -21:
			tower_map.erase_cell(cell)
	for powerup : Powerup in powerup_list.get_children():
		if powerup.position.y <= (-21 * 16):
			powerup.queue_free()
	for platform : AnimatableBody2D in platform_list.get_children():
		if platform.position.y <= (-21 * 16):
			platform.queue_free()
	for puzzle : Node in puzzle_objects.get_children():
		if puzzle is Door:
			if puzzle.position.y <= (-21 * 16):
				puzzle.queue_free()
	for child : Node in get_children():
		if child is TartPiece:
			child.queue_free()
	pieces_collected = 0
	tower_floor = 1
	tower_scrolling = true
	elevator_active = true
	
func start_tower_climb() -> void:
	await get_tree().create_timer(2).timeout
	tower_blocker.get_jumped_on()
	await get_tree().create_timer(1).timeout
	tower_blocker.get_jumped_on()
	elevator_active = true
	await get_tree().create_timer(1).timeout
	tower_scrolling = true
	
	
func collect_tart_piece() -> void:
	pieces_collected += 1
	collect_sound.play()
	queen.dialogue_state = min(3 + pieces_collected, 8)
	queen.interact()
	update_tart_hud()
	if pieces_collected == 3 && !top_generated:
		generate_end()
		await get_tree().create_timer(0.75).timeout
		complete_sound.play()

func update_tart_hud() -> void:
	return
	
func generate_end() -> void:
	top_generated = true
	tower_floor += 1
	top_y = 16 * -13 * (tower_floor + 1)
	var tower_top : TileMapLayer
	tower_top = load("res://scenes/Levels/Tower Components/tower_top.tscn").instantiate()
	for tile : Vector2i in tower_top.get_used_cells():
		tower_map.set_cell(Vector2i(0, tower_floor * -13) + tile, tower_top.get_cell_source_id(tile), tower_top.get_cell_atlas_coords(tile))
	var floor_door : Door = load("res://scenes/Puzzle Objects/door.tscn").instantiate()
	floor_door.logic_channel = 1
	floor_door.inverted = true
	floor_door.tile_width = 4
	floor_door.tile_height = 1
	floor_door.position = Vector2(-24, top_y + 100)
	puzzle_objects.add_child(floor_door)
	var final_door : Door = load("res://scenes/Puzzle Objects/door.tscn").instantiate()
	final_door.logic_channel = 1
	final_door.inverted = false
	final_door.tile_width = 2
	final_door.tile_height = 3
	final_door.position = Vector2((13.5 * 16), top_y + 64)
	puzzle_objects.add_child(final_door)
	var exit_walljump : Powerup = load("res://scenes/powerup.tscn").instantiate()
	exit_walljump.powerup_type = Powerup.POWERUPS.WALL_JUMP
	exit_walljump.powerup_count = -1
	exit_walljump.powerup_timer = -1
	exit_walljump.respawn_time = -1
	exit_walljump.position = Vector2((40.5 * 16), top_y + (-5*16))
	powerup_list.add_child(exit_walljump)
	exit_trigger.position = Vector2((36 * 16), top_y + (-25*16))
	await get_tree().create_timer(1).timeout
	elevator_active = false
	while queen.position.y - (top_y + 80) > 2:
		queen.position.y = lerp(queen.position.y, float(top_y + 80), 0.01)
		elevator.position.y = lerp(elevator.position.y, float(top_y + 100), 0.01)
		await get_tree().physics_frame
	queen.position.y = top_y + 80
	elevator.position.y = top_y + 100
	queen.dialogue_state = 9

func end_free_camera() -> void:
	camera.limit_bottom = int(camera.position.y) + 135
	camera.limit_left = -15 * 16
	camera.limit_top =  top_y + (-24*16)
	camera_following = true
	signal_bus.broadcast_logic_update.emit(1, true)
	
func queen_to_elevator() -> void:
	queen.position.x += 88
	await get_tree().create_timer(5).timeout
	queen.dialogue_state = -1
	queen.interact()
	queen.interact()
	queen.dialogue_state = 3
	queen.interact()
	#elevator_active = true

func _on_capture_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController && tower_scrolling:
		capture_player()


func _on_tower_enter_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController && !tower_scrolling:
		#tower_map.set_cell(Vector2i(-16, 4), 0, Vector2i(4, 2))
		signal_bus.broadcast_logic_update.emit(0, true)
		camera_following = false
		camera.position = Vector2(0, 0)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("secret_win_button"):
		if get_tree().current_scene.get_node("Level3Music").playing:
			var level_3_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level3Music")
			if level_3_music != null:
				level_3_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_tutorial()
		


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if get_tree().current_scene.get_node("Level3Music").playing:
			var level_3_music : AudioStreamPlayer = get_tree().current_scene.get_node("Level3Music")
			if level_3_music != null:
				level_3_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_tutorial()
