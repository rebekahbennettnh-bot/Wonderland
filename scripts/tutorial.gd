extends Node2D

@onready var tutorial_npc : NPC = $NPCs/TutorialNPC
var dialogue_state : int

func _ready() -> void:
	if get_tree().current_scene.get_node("TutorialMusic").playing:
		var tutorial_music : AudioStreamPlayer = get_tree().root.get_node("TutorialMusic")
		tutorial_music.play()


func _on_ability_trigger_1_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		body.double_jump_enabled = true
		body.update_powerup_icons()
		if dialogue_state < 1:
			dialogue_state = 1
			tutorial_npc.interact()


func _on_ability_trigger_1_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		body.double_jump_enabled = false
		body.update_powerup_icons()
