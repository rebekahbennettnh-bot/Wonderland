extends Node2D
class_name Level2

@onready var narrator : NPC = $NPCs/Narrator
@onready var dormouse : NPC = $NPCs/Dormouse
@onready var hatter : NPC = $NPCs/Hatter
@onready var player : PlayerController = $Player
@onready var camera : Camera2D = $Camera2D
@onready var signal_bus : SignalBus = $SignalBus
var dialogue_state : int
var camera_following : bool = true
var zoom_target : Vector2 = Vector2(4, 4)
var player_in_party : bool
var hatter_looking : bool

func _process(_delta: float) -> void:
	if camera_following:
		camera.position = player.position
	if camera.zoom != zoom_target:
		zoom_lerp()

func zoom_lerp() -> void:
	camera.zoom = camera.zoom.lerp(zoom_target, 0.1)
	
func hatter_sendback() -> void:
	return


func _on_party_trigger_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_party = true


func _on_party_trigger_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_in_party = false
