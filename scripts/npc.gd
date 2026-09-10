extends Node2D
class_name NPC

@onready var audio_player : AudioStreamPlayer2D =$TalkSound
@onready var sprite : AnimatedSprite2D = $NPCSprite
@onready var portrait : AnimatedSprite2D = $TextboxUI/NinePatchRect2/PortraitSprite
@export var character : CHARACTERS
@export var flip_direction : bool
@onready var textbox_ui : CanvasLayer = $TextboxUI
@onready var text_field : Label = $TextboxUI/NinePatchRect/TextField
@onready var nametag : Label = $TextboxUI/Name
var player_intersecting : bool
var dialogue_state : int = 0
var portrait_visible : bool
enum CHARACTERS {SILPH, GELI}

func _ready() -> void:
	textbox_ui.hide()
	if character == CHARACTERS.SILPH:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Silph"
		portrait_visible = false
	elif character == CHARACTERS.GELI:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Geli"
		portrait_visible = true
	sprite.flip_h = flip_direction
	nametag.position = Vector2(240 - (nametag.size.x / 2), 246)
	if portrait_visible:
		nametag.position += Vector2(24, 0)
	sprite.play("idle")
	return

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_intersecting = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_intersecting = false


func _input(_event: InputEvent) -> void:
	#if player_intersecting && Input.is_action_pressed("dash") && !audio_player.playing:
	#	audio_player.play()
	if player_intersecting && Input.is_action_just_pressed("interact"):
		interact()
		
func interact() -> void:
	var new_text : String = dialogue_tree()
	if new_text != "":
		#print(new_text)
		display_dialogue(new_text)

func display_dialogue(new_text : String) -> void:
	textbox_ui.show()
	text_field.text = new_text
	text_field.visible_characters = 0
	while (text_field.visible_characters < text_field.text.length()):
		text_field.visible_characters += 1
		for i in 5:
			await get_tree().process_frame
		if !audio_player.playing:
			audio_player.play()
	await get_tree().create_timer(0.05 * text_field.visible_characters + 2).timeout
	textbox_ui.hide()
	
#This may need to be moved to a separate script or object at some point,
#just to maintain clarity and avoid a huge tree, but it works for now
func dialogue_tree() -> String:
	if character == CHARACTERS.SILPH:
		if dialogue_state == 0:
			dialogue_state += 1
			return "..."
		elif dialogue_state == 1:
			return "...(The figure stays silent.)"
	elif character == CHARACTERS.GELI:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Is this a new framing device?\nWhat a fascinating dream!"
		elif dialogue_state == 1:
			dialogue_state += 1
			return "Only, it could do with some more excitement."
		elif dialogue_state == 2:
			dialogue_state += 1
			return "I have an idea. Ready?"
		elif dialogue_state == 3:
			var new_slime : Slime = preload("res://scenes/slime.tscn").instantiate()
			new_slime.position = self.position + Vector2(64, 41)
			add_child(new_slime)
			return ""
	return ""
