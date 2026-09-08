extends Node

var coins_collected : int
@onready var end_text : Label = $EndText

func _ready() -> void:
	update_text()
	if !Music.playing:
		Music.play()

func update_text() -> void:
	end_text.text = "Congratulations!\n"
	end_text.text += "You collected " + str(coins_collected) + " coins!"
