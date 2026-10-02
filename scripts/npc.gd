extends Node2D
class_name NPC

@onready var audio_player : AudioStreamPlayer2D =$TalkSound
@onready var sprite : AnimatedSprite2D = $NPCSprite
@onready var portrait : AnimatedSprite2D = $TextboxUI/PortraitRect/PortraitSprite
@export var character : CHARACTERS
@export var flip_direction : bool
@onready var textbox_ui : CanvasLayer = $TextboxUI
@onready var textbox : NinePatchRect = $TextboxUI/TextboxRect
@onready var text_field : Label = $TextboxUI/TextboxRect/TextField
@onready var nametag : Label = $TextboxUI/Name
@onready var portrait_box : NinePatchRect = $TextboxUI/PortraitRect
var choice_box : DialogueChoice
var player_intersecting : bool
var dialogue_state : int = 0
var talking : bool
var portrait_visible : bool
enum CHARACTERS {SILPH, GELI, TUTORIAL_NARRATOR, CHESHIRE_CAT, LEVEL1_NARRATOR, MAD_HATTER, DORMOUSE, LEVEL2_NARRATOR, CARD_GUARD, QUEEN_OF_HEARTS, LEVEL3_NARRATOR}
var narrator_tracker : int
var can_interact : bool = true

func _ready() -> void:
	var root_reference : RootNode = get_tree().current_scene
	narrator_tracker = root_reference.narrator_tracker
	textbox_ui.hide()
	if character == CHARACTERS.SILPH:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Silph"
		portrait_visible = false
	elif character == CHARACTERS.GELI:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Geli"
		portrait_visible = true
	elif character == CHARACTERS.TUTORIAL_NARRATOR:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = ""
		portrait_visible = false
	elif character == CHARACTERS.CHESHIRE_CAT:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Cheshire Cat"
		portrait_visible = true
		textbox_ui.layer += 1
	elif character == CHARACTERS.LEVEL1_NARRATOR:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = ""
		portrait_visible = false
	elif character == CHARACTERS.MAD_HATTER:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Mad Hatter"
		portrait_visible = true
	elif character == CHARACTERS.DORMOUSE:
		sprite.sprite_frames = preload("res://assets/Resources/dormouse_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/dormouse_portrait_spriteframe.tres")
		nametag.text = "Dormouse"
		portrait_visible = true
	elif character == CHARACTERS.LEVEL2_NARRATOR:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = ""
		portrait_visible = false
	elif character == CHARACTERS.CARD_GUARD:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Card Guard"
		portrait_visible = true
	elif character == CHARACTERS.QUEEN_OF_HEARTS:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = "Queen of Hearts"
		portrait_visible = true
	elif character == CHARACTERS.LEVEL3_NARRATOR:
		sprite.sprite_frames = preload("res://assets/Resources/placeholder_spriteframe.tres")
		portrait.sprite_frames = preload("res://assets/Resources/placeholder_portrait_spriteframe.tres")
		nametag.text = ""
		portrait_visible = false
	sprite.flip_h = flip_direction
	nametag.position = Vector2(264 - (nametag.size.x / 2), 246)
	if !portrait_visible:
		nametag.position -= Vector2(24, 0)
		portrait_box.visible = false
		textbox.position.x -= 48
		textbox.size.x += 48
		text_field.custom_maximum_size.x += 48
	sprite.play("idle")
	portrait.play("idle")
	if character == CHARACTERS.DORMOUSE:
		sprite.play("sleeping")
		portrait.play("sleeping")
	return

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_intersecting = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_intersecting = false


func _input(_event: InputEvent) -> void:
	#if player_intersecting && Input.is_action_pressed("dash") && !audio_player.playing:
	#	audio_player.play()
	if player_intersecting && Input.is_action_just_pressed("interact") && choice_box == null && can_interact:
		interact()
		
func interact() -> void:
	if talking:
		if text_field.visible_characters == text_field.text.length():
			talking = false
			textbox_ui.hide()
		else:
			talking = false
	else:
		textbox_ui.hide()
		var new_text : String = dialogue_tree()
		if new_text != "":
			#print(new_text)
			display_dialogue(new_text)

func display_dialogue(new_text : String) -> void:
	talking = true
	textbox_ui.show()
	text_field.text = new_text
	text_field.visible_characters = 0
	while (text_field.visible_characters < text_field.text.length() && talking):
		text_field.visible_characters += 1
		for i in 5:
			await get_tree().process_frame
		if !audio_player.playing:
			audio_player.play()
	talking = false
	text_field.visible_characters = text_field.text.length()
	await get_tree().create_timer(0.05 * text_field.visible_characters + 2).timeout
	if text_field.text == new_text:
		textbox_ui.hide()
	
#This may need to be moved to a separate script or object at some point,
#just to maintain clarity and avoid a huge tree, but it works for now
func dialogue_tree() -> String:
	if character == CHARACTERS.SILPH:
		if dialogue_state == 0:
			dialogue_state += 1
			return "..."
		elif dialogue_state == 1:
			dialogue_state += 1
			return "...(The figure stays silent.)"
		elif dialogue_state == 2:
			var choice1 = func():
				var new_slime : Slime = preload("res://scenes/slime.tscn").instantiate()
				new_slime.position = self.position + Vector2(-64, 36)
				get_parent().add_child(new_slime)
			var choice2 = func():
				var new_slime : Slime = preload("res://scenes/slime.tscn").instantiate()
				new_slime.position = self.position + Vector2(64, 36)
				new_slime.direction *= -1
				get_parent().add_child(new_slime)
			prompt_choice(PackedStringArray(["Left slime, please", "Right slime, please", "Secret third thing"]), [choice1, choice2, func(): print("secret")])
	elif character == CHARACTERS.GELI:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Is this a new framing device?\nWhat a fascinating dream!"
		elif dialogue_state == 1:
			dialogue_state += 1
			return "Only, it could do with some more excitement."
		elif dialogue_state == 2:
			dialogue_state += 1
			return "I have an idea. Ready?"
		elif dialogue_state == 3:
			var new_slime : Slime = preload("res://scenes/slime.tscn").instantiate()
			new_slime.position = self.position + Vector2(64, 41)
			add_child(new_slime)
			return ""
	elif character == CHARACTERS.TUTORIAL_NARRATOR:
		if dialogue_state == 0:
			dialogue_state += 1
			return "(SPACE to double jump)"
		elif dialogue_state == 1:
			dialogue_state += 1
			return "(SHIFT to dash)"
		elif dialogue_state == 2:
			dialogue_state += 1
			return "(SPACE + A/D to wall jump)"
		if dialogue_state == 3:
			dialogue_state += 1
			return "Oh...\nHello there."
		elif dialogue_state == 4:
			dialogue_state += 3
			return "I'm the narrator. You aren't supposed to be in here. All I do for now is tell you about your abilities."
		elif dialogue_state == 5:
			dialogue_state += 1
			return "Every textbox has to come from somewhere, of course. Why not make it diagetic?"
		elif dialogue_state == 6:
			dialogue_state += 1
			return "Look, it would be best if you went back to the level and forgot this happened. I'll send you to the start, okay?"
		elif dialogue_state == 7:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 1
			var choice1 = func():
				var player_ref : PlayerController = get_parent().get_parent().get_node("Player")
				player_ref.position = Vector2(0, -208)
			var choice2 = func():
				print("Empty choice picked.")
			var choice3 = func():
				self.dialogue_state = 8
				self.interact()
			dialogue_state -= 1
			prompt_choice(PackedStringArray(["Okay.", "I can get back on my own.", "Will I see you again?"]), [choice1, choice2, choice3])
		elif dialogue_state == 8:
			dialogue_state = 6
			#var root_node : RootNode = get_tree().current_scene
			#root_node.narrator_tracker = 1
			return "Possibly, if you keep poking around like this. You shouldn't, though. I can't promise there will be anything else for you."
	elif character == CHARACTERS.CHESHIRE_CAT:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Hello again, Not Stranger.\nI am the Cheshire Cat."
		elif dialogue_state == 1:
			dialogue_state += 1
			return "That extra jump you made, such a familiar sight. That was the power of Wonderland."
		elif dialogue_state == 2:
			dialogue_state += 1
			return "Now you're here, you'll have to learn to share. Don't expect it to last forever!"
		if dialogue_state == 3:
			cheshire_fadeout()
			return "Now, if you want to pass, I need a favor in turn. Come a little further and help me find my head. I'll be waiting for you..."
		elif dialogue_state == 4:
			dialogue_state += 1
			return "You've made it. Now, I need your help to find my head."
		elif dialogue_state == 5:
			dialogue_state += 1
			return "I worry the Queen wants it, so it's good to keep a spare. It should be just behind those striped blocks."
		elif dialogue_state == 6:
			dialogue_state += 1
			return "Pull all nine levers and then I'll let you through.\nHop to it, rabbit!"
		elif dialogue_state == 7:
			return "You still haven't pulled all the levers."
		elif dialogue_state == 8:
			dialogue_state += 1
			var level_ref : Level1 = get_parent().get_parent()
			level_ref.signal_bus.broadcast_logic_update.emit(10, true)
			return "Nicely done, it looks just like me. I'll let you through now."
		elif dialogue_state == 9:
			return "Best of luck up ahead. I don't fancy the Queen will let you past again."
	elif character == CHARACTERS.LEVEL1_NARRATOR:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Press E to interact with characters and levers."
		elif dialogue_state == 1:
			if narrator_tracker == 0:
				dialogue_state += 1
				return "Oh...\nHello there."
			else:
				dialogue_state = 6
				return "Oh!\nHello again."
		elif dialogue_state == 2:
			dialogue_state += 1
			return "I'm the narrator. You aren't supposed to be in here. All I do here is teach you to interact."
		elif dialogue_state == 3:
			dialogue_state += 1
			return "Every textbox has to come from somewhere, of course. Why not make it diagetic?"
		if dialogue_state == 4:
			dialogue_state += 1
			return "I'm sorry, perhaps if we had met earlier, I might have more to say to you. For now, though, the only thing to do is return to the level."
		elif dialogue_state == 5:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 1
			return "..."
		elif dialogue_state == 6:
			dialogue_state += 1
			return "You've found me a second time. I guess you like backtracking."
		elif dialogue_state == 7:
			dialogue_state += 1
			return "I'm here to let you know about interacting, which you seem to know how to do already."
		elif dialogue_state == 8:
			dialogue_state += 1
			return "In that case, I really don't know what else to offer you. I could send you back to the puzzle if you want?"
		elif dialogue_state == 9:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 2
			var choice1 = func():
				self.dialogue_state = 10
				self.interact()
			var choice2 = func():
				var player_ref : PlayerController = get_parent().get_parent().get_node("Player")
				player_ref.position = Vector2(0, -208)
			var choice3 = func():
				print("Empty choice picked.")
			dialogue_state -= 1
			prompt_choice(PackedStringArray(["Will you be in the next level too?", "Sounds good.", "I'd rather walk."]), [choice1, choice2, choice3])
		elif dialogue_state == 10:
			dialogue_state = 8
			#var root_node : RootNode = get_tree().current_scene
			#root_node.narrator_tracker = 2
			return "I assume so, as long as there are things to be explained. Planning to look for me again, are you?"
	elif character == CHARACTERS.MAD_HATTER:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Ah, welcome back, rabbit! We're having a tea party! It is teatime, after all."
		elif dialogue_state == 1:
			dialogue_state += 1
			return "You seemed in such a hurry before. This time, you MUST do us the honor of staying for tea."
		elif dialogue_state == 2:
			dialogue_state = 4
			return "Now, stay in that chair and enjoy your tea. It wouldn't do to let it get cold."
		elif dialogue_state == 3:
			return "What are you doing? Get back to your seat."
		elif dialogue_state == 4:
			return "Why are you here? Unless you have something for me, get back to your seat."
		elif dialogue_state == 5:
			dialogue_state += 1
			return "A cake? For me...?\nHow insensitive!"
		elif dialogue_state == 6:
			return "You need some for the Dormouse and yourself as well. This is a tea party, I won't eat while the guests go hungry. Now, back to your seat!"
		elif dialogue_state == 7:
			return "Cakes to go with the tea? What a fantastic idea! I'll eat all three, I assume you have your own."
	elif character == CHARACTERS.DORMOUSE:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Zzzzz..."
		elif dialogue_state == 1:
			dialogue_state += 1
			sprite.play("idle")
			portrait.play("idle")
			return "...Hm?\nOh, hello. I am the Dormouse."
		elif dialogue_state == 2:
			dialogue_state += 1
			return "Are you here for the tea party? It's dreadfully tiring, and the Hatter won't let me leave. Not that I have the energy to do so."
		elif dialogue_state == 3:
			cheshire_fadeout()
			return "I should really get back to my seat now. It's more comfortable to sleep on than the ground."
		elif dialogue_state == 4:
			dialogue_state += 1
			sprite.play("idle")
			portrait.play("idle")
			return "Zzzzz...\nHello again. I assume you met the Hatter? He can be rather insistent."
		elif dialogue_state == 5:
			dialogue_state += 1
			return "If you want to keep going, you should do us both a favor and deal with him. I'd prefer to sleep without being used as a cushion or dunked in tea."
		elif dialogue_state == 6:
			dialogue_state += 1
			#return "Like the potions that shrink you, there are some cakes around that make you huge. I'll bet if you gave one to the Hatter, he would be too big to even notice us leave."
			return "There are some cakes around that make you grow huge. I'll bet if you gave one to the Hatter, he would be too big to even notice us leave."
		elif dialogue_state == 7:
			dialogue_state += 1
			return "He likes riddles, too, so I'll bet he won't mind if I give you a prize if you answer correctly."
		elif dialogue_state == 8:
			return "Now, go distract him and quit interrupting my naps."
	elif character == CHARACTERS.LEVEL2_NARRATOR:
		#if dialogue_state == 0:
			#dialogue_state += 1
			#return "You can fit through small spaces after drinking a green potion, but can't jump as high."
		if dialogue_state == 0:
			dialogue_state += 1
			return "You can move while the Hatter's back is turned. If you get caught, you must return to your seat."
		elif dialogue_state == 1:
			if narrator_tracker == 0:
				dialogue_state += 1
				return "Oh...\nHello there."
			elif narrator_tracker == 1:
				dialogue_state = 6
				return "Oh...\nHello again."
			else:
				dialogue_state = 10
				return "Oh, hello!\nI was hoping you would show up."
		elif dialogue_state == 2:
			dialogue_state += 1
			return "I'm the narrator. You aren't supposed to be in here. All I do here is teach you about growing cakes."
		elif dialogue_state == 3:
			dialogue_state += 1
			return "Every textbox has to come from somewhere, of course. Why not make it diagetic?"
		if dialogue_state == 4:
			dialogue_state += 1
			return "I'm sorry, perhaps if we had met earlier, I might have more to say to you. For now, though, the only thing to do is return to the level."
		elif dialogue_state == 5:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 1
			return "..."
		elif dialogue_state == 6:
			dialogue_state += 1
			return "You've found me again. I'm just here to let you know about growing cakes."
		elif dialogue_state == 7:
			dialogue_state += 1
			return "Look, I apologize, but there is really nothing I can do for you right now."
		elif dialogue_state == 8:
			dialogue_state += 1
			return "If I had met you back in the tutorial, I might have an idea, but the way things have gone, I'm just not feeling inspired."
		elif dialogue_state == 9:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 2
			return "..."
		elif dialogue_state == 10:
			dialogue_state += 1
			return "You see, I've had an idea. The fact that you keep finding me suggests you want to get all you can out of this game, right?"
		elif dialogue_state == 11:
			dialogue_state += 1
			return "Well, what if I were to help you try something new?\nWaiting around to say one line of narration gets boring, so I've been working on a side project."
		elif dialogue_state == 11:
			dialogue_state += 1
			return "If you can find me in the next stage, I'll let you test it out.\nNow, you know the drill - I can return you to the level if you want."
		elif dialogue_state == 12:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 3
			var choice1 = func():
				self.dialogue_state = 13
				self.interact()
			var choice2 = func():
				var player_ref : PlayerController = get_parent().get_parent().get_node("Player")
				player_ref.position = Vector2(0, -208)
			var choice3 = func():
				print("Empty choice picked.")
			dialogue_state -= 1
			prompt_choice(PackedStringArray(["Could I get some sort of hint?", "Yep, send me back.", "No thanks."]), [choice1, choice2, choice3])
		elif dialogue_state == 13:
			dialogue_state = 11
			#var root_node : RootNode = get_tree().current_scene
			#root_node.narrator_tracker = 2
			return "I guess so, since I really do hope you succeed. I'll not be far from where you begin, so don't be afraid of backtracking."
	elif character == CHARACTERS.CARD_GUARD:
		if dialogue_state == 0:
			dialogue_state += 1
			return "..."
		elif dialogue_state == 1:
			return "...(The figure stays silent.)"
	elif character == CHARACTERS.QUEEN_OF_HEARTS:
		if dialogue_state == 0:
			dialogue_state += 1
			return "..."
		elif dialogue_state == 1:
			return "...(The figure stays silent.)"
	elif character == CHARACTERS.LEVEL3_NARRATOR:
		if dialogue_state == 0:
			dialogue_state += 1
			return "Press E to interact with characters and levers."
		elif dialogue_state == 1:
			if narrator_tracker == 0:
				dialogue_state += 1
				return "Oh...\nHello there."
			elif narrator_tracker == 1 || narrator_tracker == 2:
				dialogue_state = 6
				return "Oh...\nHello again."
			else:
				dialogue_state = 10
				return "Oh, hello!\nYou made it!"
		elif dialogue_state == 2:
			dialogue_state += 1
			return "I'm the narrator. You aren't supposed to be in here. All I do here is teach you about the tower."
		elif dialogue_state == 3:
			dialogue_state += 1
			return "Every textbox has to come from somewhere, of course. Why not make it diagetic?"
		if dialogue_state == 4:
			dialogue_state += 1
			return "I'm sorry, perhaps if we had met earlier, I might have more to say to you. For now, though, the only thing to do is return to the level."
		elif dialogue_state == 5:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 1
			return "..."
		elif dialogue_state == 6:
			dialogue_state += 1
			return "You've found me again. I'm just here to teach you about the tower."
		elif dialogue_state == 7:
			dialogue_state += 1
			return "Look, I apologize, but there is really nothing I can do for you right now."
		elif dialogue_state == 8:
			dialogue_state += 1
			return "If I had met you back in the tutorial, I might have an idea, but the way things have gone, I'm just not feeling inspired."
		elif dialogue_state == 9:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 2
			return "..."
		elif dialogue_state == 10:
			dialogue_state += 1
			return "So, about the secret project.\nWell, you've really pushed the platformer to its limits, so my thought was to introduce another genre."
		elif dialogue_state == 11:
			dialogue_state += 1
			return "When you get back to the top of the tower - I can send you there once we finish talking - the gate on the left will be open."
		elif dialogue_state == 12:
			dialogue_state += 1
			return "Now, I'm not one to spoil the surprise, but nor will I let you go unprepared. Take this vorpal sword, and remember: Beware the Jabberwock, my friend!"
		elif dialogue_state == 13:
			var root_node : RootNode = get_tree().current_scene
			root_node.narrator_tracker = 4
			var choice1 = func():
				self.dialogue_state = 14
				self.interact()
			var choice2 = func():
				var player_ref : PlayerController = get_parent().get_parent().get_node("Player")
				player_ref.position = Vector2(0, -208)
			var choice3 = func():
				print("Empty choice picked.")
			#dialogue_state -= 1
			prompt_choice(PackedStringArray(["You're sending me into danger?", "Alright, take me to the top.", "I can climb back up."]), [choice1, choice2, choice3])
		elif dialogue_state == 14:
			dialogue_state = 13
			#var root_node : RootNode = get_tree().current_scene
			#root_node.narrator_tracker = 2
			return "Don't worry, you'll respawn at the top of the tower if anything goes wrong. Now, should I teleport you?"
		elif dialogue_state == 15:
			return "Okay, I realize I never taught you how to use that sword. I suppose it's time for a bit more narration."
		elif dialogue_state == 16:
			return "Use ENTER or LEFT CLICK to swing the vorpal sword."
		elif dialogue_state == 17:
			return "Swing just before you get hit to parry."
		elif dialogue_state == 18:
			return "You will lose a powerup when hit. If hit without powerups, you die and respawn."
		elif dialogue_state == 19:
			return "As the Jabberwock's health lowers, it will retreat towards to the surface. Stop it before it escapes Wonderland!"
	return ""
	
func prompt_choice(choices : PackedStringArray, outcomes : Array[Callable]) -> void:
	if outcomes.size() == choices.size():
		var new_choice_box : DialogueChoice = preload("res://scenes/Functionality/dialogue_choice.tscn").instantiate()
		add_child(new_choice_box)
		new_choice_box.construct(choices, outcomes, self)
		choice_box = new_choice_box
		choice_box.initiate_choice()
		
func cheshire_fadeout() -> void:
	can_interact = false
	var alpha : float = 1.0
	await get_tree().create_timer(1).timeout
	while (talking):
		await get_tree().process_frame
	while (alpha >= 0.005):
		alpha -= 0.005
		sprite.self_modulate.a = alpha
		await get_tree().process_frame
	while (textbox_ui.visible):
		await get_tree().process_frame
	queue_free() 
