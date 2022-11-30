extends Node2D

var text_chunks = [
			"Before every session of tabletop gaming",
			"Players test their dice to discover their worth",
			"but to be named Blessed or Cursed a dice must be victorious",
			"in the Arena of Fate and be proclaimed by the…"
			]
var count = 0
var col1 = Color(1, 1, 1, 0)
var col2 = Color(1, 1, 1, 1)

onready var world = preload("res://Scenes/world.tscn")

onready var intro_sound = preload("res://Assets/Music/Intro_transition.wav")
onready var explode_dice_sound = preload("res://Assets/Sounds/Exploding_dice.wav")

func _ready():
	play_music(1, intro_sound, 0, $AudioStreamPlayer)
	for i in text_chunks.size():
		fade_in_text(text_chunks[i], $CanvasLayer/Text_chunks)
		yield($Tween, "tween_completed")
		fade_out_text($CanvasLayer/Text_chunks)
		yield($Tween, "tween_completed")
	
	col1 = Color(0.98, 0.29, 0.29, 0)
	col2 = Color(0.98, 0.29, 0.29, 1)
	
	fade_in_text("POLYHEDRAL GODS", $CanvasLayer/Title)
	soundFX(0.3, explode_dice_sound, 10, $AudioStreamPlayer)
	yield($Tween, "tween_completed")
	
	fade_out_text($CanvasLayer/Title)
	yield($Tween, "tween_completed")
	
	start_game()

func fade_in_text(t, target):
	#$CanvasLayer/Text_chunks.text = t
	target.text = t
	$Tween.interpolate_property(target, "modulate", col1, col2, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func fade_out_text(target):
	$Tween.interpolate_property(target, "modulate", col2, col1, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

#func _physics_process(delta : float) -> void:
func _unhandled_input(_event) -> void:
	#if any button pressed, skip
	if Input.is_action_just_pressed("left_click"):
		start_game()

func start_game():
	var failed = get_tree().change_scene("res://Scenes/world.tscn")
	if failed:
		print("Failed scene transition.")


func play_music(pitch, sound, vol_boost, music_player):
	if settings.music_enabled:
		if music_player.get_stream() != sound:
			music_player.set_stream(sound)
		music_player.volume_db = settings.music_volume + vol_boost
		music_player.pitch_scale = pitch
		music_player.play()

func soundFX(pitch, sound, vol_boost, sound_player):
	if settings.fx_enabled:
		if sound_player.get_stream() != sound:
			sound_player.set_stream(sound)
		sound_player.volume_db = settings.fx_volume + vol_boost
		sound_player.pitch_scale = pitch
		sound_player.play()
