extends Area2D

@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("You died!")
		Engine.time_scale = 0.25
		body.get_node("CollisionShape2D").queue_free()
		timer.start()


func _on_timer_timeout() -> void:
	#Music.stop()
	Engine.time_scale = 1.0
	get_tree().current_scene.reset_game()
