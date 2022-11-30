extends Node2D

var score : int = 0

var game_over : bool = false
var map_scale : float = 2
var map_size : Vector2 = Vector2(1920, 1080) * map_scale # Vector2(1920, 1080)

onready var orchestral_loop_1 = preload("res://Assets/Music/Orchestral_loop_1.wav")
onready var percussive_loop_2 #= preload("res://Assets/Music/Percussive_loop_2.wav")
#onready var bass_loop_3 #= preload("res://Assets/Music/Bass_loop_3.wav")
#onready var 

func _ready():
	start_track(1)
	$Map.scale = Vector2(map_scale, map_scale)
	$Player.position = Vector2(map_size.x/2, 200)

func add_score(num):
	if !game_over:
		score += num
		$HUD/Score.text = "SCORE: " + str(score)

func gameover():
	if !game_over:
		$Music1.volume_db -= 10
		$Music2.volume_db -= 10
	
	game_over = true
	$PlayerTrail.visible = false
	
	# End score
	#$HUD/Score.rect_scale = Vector2(2, 2)
	$HUD/Score.rect_position.y = 250
	
	$HUD/HBoxContainer.visible = true
	$HUD/Gameover.visible = true
	#$HUD/Dice.position = $HUD/Ranking.rect_position + Vector2(0, 50)
	$HUD/rankdice/Dice.visible = true
	
	# FIRE PARTICLES
#	$HUD/Labels/BigShotParticles.position = $HUD/rankdice/Dice.position
#	$HUD/Labels/BigShotParticles.emitting = true
	
	#setting ranking
	$HUD/Ranking.text = str(round((float(score)/25000) * 8))
	
	# Restart button
	$HUD/HBoxContainer/RestartButton.disabled = false
	# Quit to menu button
	$HUD/HBoxContainer/QuitButton.disabled = false
	pass

func start_track(track):
	match track:
		1:
			play_music(1, orchestral_loop_1, 10, $Music1)
		2:
			percussive_loop_2 = load("res://Assets/Music/Percussive_loop_2.wav")
			play_music(1, percussive_loop_2, 10, $Music2)
		3:
			pass
			#play_music(1, bass_loop_3, 5, $Music3)

func play_music(pitch, sound, vol_boost, music_player):
	if settings.music_enabled:
		if music_player.get_stream() != sound:
			music_player.set_stream(sound)
		music_player.volume_db = settings.music_volume + vol_boost
		music_player.pitch_scale = pitch
		music_player.play()

func _on_RestartButton_pressed():
	var failed = get_tree().change_scene("res://Scenes/world.tscn")
	if failed:
		print("Failed scene transition.")

func _on_QuitButton_pressed():
	var failed = get_tree().change_scene("res://Scenes/Menu.tscn")
	if failed:
		print("Failed scene transition.")
