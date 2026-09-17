extends Node2D
class_name SignalBus

signal broadcast_logic_update(channel : int, active : bool)

func _ready() -> void:
	if get_parent().name == "Tutorial":
		return
	if %PuzzleObjects:
		for c in %PuzzleObjects.get_children():
			if c is Lever:
				c.update_toggled.connect(receive_logic_update)

func receive_logic_update(channel : int, active : bool) -> void:
	broadcast_logic_update.emit(channel, active)
