extends Node2D

@onready var tutorial_npc : NPC = $NPCs/TutorialNPC
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
			tutorial_npc.interact()


func _on_ability_trigger_2_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if dialogue_state == 1:
			dialogue_state = 2
			tutorial_npc.interact()


func _on_ability_trigger_3_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if dialogue_state == 2:
			dialogue_state = 3
			tutorial_npc.interact()
