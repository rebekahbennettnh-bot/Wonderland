extends Node2D

@onready var tutorial_npc : NPC = $NPCs/Narrator
var dialogue_state : int

func _ready() -> void:
	if !get_tree().current_scene.get_node("TutorialMusic").playing:
		var tutorial_music : AudioStreamPlayer = get_tree().current_scene.get_node("TutorialMusic")
		if tutorial_music != null:
			tutorial_music.play()


func _on_ability_trigger_1_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if dialogue_state < 1:
			dialogue_state = 1
			#tutorial_npc.interact()
			tutorial_npc.textbox_ui.hide()
			var new_text : String = tutorial_npc.dialogue_tree()
			if new_text != "":
				tutorial_npc.display_dialogue(new_text)


func _on_ability_trigger_2_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if dialogue_state == 1:
			dialogue_state = 2
			#tutorial_npc.interact()
			tutorial_npc.textbox_ui.hide()
			var new_text : String = tutorial_npc.dialogue_tree()
			if new_text != "":
				tutorial_npc.display_dialogue(new_text)


func _on_ability_trigger_3_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if dialogue_state == 2:
			dialogue_state = 3
			#tutorial_npc.interact()
			tutorial_npc.textbox_ui.hide()
			var new_text : String = tutorial_npc.dialogue_tree()
			if new_text != "":
				tutorial_npc.display_dialogue(new_text)


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if get_tree().current_scene.get_node("TutorialMusic").playing:
			var tutorial_music : AudioStreamPlayer = get_tree().current_scene.get_node("TutorialMusic")
			if tutorial_music != null:
				tutorial_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_level_1()

func _on_secret_exit_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if get_tree().current_scene.get_node("TutorialMusic").playing:
			var tutorial_music : AudioStreamPlayer = get_tree().current_scene.get_node("TutorialMusic")
			if tutorial_music != null:
				tutorial_music.stop()
		var root : RootNode = get_tree().current_scene
		root.start_test_plane()
