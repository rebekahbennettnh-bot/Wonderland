extends Node2D

@export var alphabg : ColorRect
@export var cancel_button : Button
@export var wpi_splash : Sprite2D
@export var credits : ScrollContainer
@export var version : ScrollContainer
@export var cancel_button_sound : AudioStreamPlayer
@export var open_button_sound : AudioStreamPlayer
@export var menu_music : AudioStreamPlayer
var popup_selected : int
enum POPUPS {NONE, CREDITS, VERSION}


func _ready() -> void:
	menu_music.play()
	wpi_splash.visible = true
	alphabg.visible = true
	alphabg.color.a = 1.0
	splash_fadeout()
	var nineslicec : NinePatchRect = credits.get_child(0).get_child(0)
	nineslicec.custom_minimum_size = nineslicec.get_parent_control().size
	nineslicec.custom_maximum_size = nineslicec.get_parent_control().size
	var nineslicev : NinePatchRect = version.get_child(0).get_child(0)
	nineslicev.custom_minimum_size = nineslicev.get_parent_control().size
	nineslicev.custom_maximum_size = nineslicev.get_parent_control().size

func splash_fadeout() -> void:
	var alpha : float = 1.0
	await get_tree().create_timer(1.5).timeout
	while (alpha >= 0.0025):
		alpha -= 0.0025
		alphabg.color.a = alpha
		wpi_splash.self_modulate.a = alpha
		await get_tree().process_frame
	alphabg.visible = false
	wpi_splash.visible = false
	alphabg.color.a = 0.75

func _on_play_button_pressed() -> void:
	open_button_sound.play()
	var game = preload("res://scenes/Levels/tutorial.tscn").instantiate()
	get_parent().start_level(game)

func _on_credits_button_pressed() -> void:
	open_button_sound.play()
	popup_selected = POPUPS.CREDITS
	credits.visible = true
	version.visible = false
	cancel_button.visible = true
	alphabg.visible = true


func _on_version_button_pressed() -> void:
	open_button_sound.play()
	popup_selected = POPUPS.VERSION
	credits.visible = false
	version.visible = true
	cancel_button.visible = true
	alphabg.visible = true


func _on_cancel_button_pressed() -> void:
	cancel_button_sound.play()
	popup_selected = POPUPS.NONE
	credits.visible = false
	version.visible = false
	cancel_button.visible = false
	alphabg.visible = false


func _on_test_button_pressed() -> void:
	open_button_sound.play()
	var game = preload("res://scenes/Levels/test_plane.tscn").instantiate()
	get_parent().start_level(game)
