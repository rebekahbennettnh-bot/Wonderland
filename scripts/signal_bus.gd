extends Node2D
class_name SignalBus

signal broadcast_logic_update(channel : int, active : bool)

func _ready() -> void:
	broadcast_logic_update.emit(1, false)
