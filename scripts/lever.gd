extends Area2D

@export var logic_channel : int
var player_intersecting : bool
var toggled : bool
signal update_toggled(channel : int, active : bool)

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
	update_toggled.emit(logic_channel, toggled)
