extends Node2D
class_name DialogueChoice


var choices : PackedStringArray
var outcomes : Array[Callable]
var parent_reference : NPC
var player_reference : PlayerController
@onready var textbox_ui : CanvasLayer = $TextboxUI
@onready var textbox : Label = $TextboxUI/TextboxRect/TextField
@onready var up_arrow : TextureButton = $TextboxUI/TextboxRect/UpArrow
@onready var down_arrow : TextureButton = $TextboxUI/TextboxRect/DownArrow
var selection : int
var options : int

func construct(choices_arg : PackedStringArray, outcomes_arg : Array[Callable], parent_arg : NPC):
	choices = choices_arg
	outcomes = outcomes_arg
	parent_reference = parent_arg
	selection = 0
	options = choices.size()
	change_shown()

func initiate_choice() -> void:
	player_reference = parent_reference.get_parent().get_parent().get_node("Player")
	if player_reference != null:
		player_reference.movement_frozen = true
	textbox_ui.show()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_up"):
		up_arrow.pressed.emit()
	elif Input.is_action_just_pressed("move_down"):
		down_arrow.pressed.emit()
	elif Input.is_action_just_pressed("interact"):
		choose_option()
		
func change_shown() -> void:
	textbox.text = choices[selection]
	up_arrow.visible = true
	down_arrow.visible = true
	if selection == 0:
		up_arrow.visible = false
	if selection == options - 1:
		down_arrow.visible = false
		
func choose_option() -> void:
	outcomes[selection].call()
	if player_reference != null:
		player_reference.movement_frozen = false
	textbox_ui.hide()
	await get_tree().process_frame
	parent_reference.choice_box = null
	queue_free()

func _on_up_arrow_pressed() -> void:
	if selection > 0:
		selection -= 1
		change_shown()

func _on_down_arrow_pressed() -> void:
	if selection < (options - 1):
		selection += 1
		change_shown()
