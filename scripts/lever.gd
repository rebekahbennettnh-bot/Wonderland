extends Area2D
class_name Lever

@export var logic_channel : int
@onready var sprite : Sprite2D = $Sprite2D
@onready var sfx : AudioStreamPlayer = $"513481BudekClick"
var player_intersecting : bool
var toggled : bool
signal update_toggled(channel : int, active : bool)

func _ready() -> void:
	update_sprite()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_intersecting = true


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_intersecting = false


func _input(_event: InputEvent) -> void:
	#if player_intersecting && Input.is_action_pressed("dash") && !audio_player.playing:
	#	audio_player.play()
	if player_intersecting && Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	toggled = !toggled
	sfx.pitch_scale = 1
	if !toggled:
		sfx.pitch_scale = 0.75
	sfx.play()
	update_toggled.emit(logic_channel, toggled)
	update_sprite()

func update_sprite() -> void:
	sprite.region_enabled = true
	if toggled:
		sprite.region_rect = Rect2(0, 0, 32, 32)
	else:
		sprite.region_rect = Rect2(0, 32, 32, 32)
