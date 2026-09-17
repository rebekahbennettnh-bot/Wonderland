extends AnimatableBody2D

@export var logic_channel : int
@export var inverted : bool

@onready var signal_bus : SignalBus = %SignalBus

func _ready() -> void:
	signal_bus.broadcast_logic_update.connect(update_logic)

func update_logic(channel : int, active : bool) -> void:
	if channel == logic_channel:
		if inverted:
			visible = active
			set_collision_layer_value(7, active)
		else:
			visible = !active
			set_collision_layer_value(7, !active)
		
