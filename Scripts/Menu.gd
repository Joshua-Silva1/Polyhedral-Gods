extends Control
#
#func _ready():
#	$MenuMusic.volume_db = settings.music_volume
#	if settings.music_enabled:
#		$MenuMusic.play(settings.music_playback_position)
#	$VBoxContainer/StartButton.grab_focus()
#

func _on_StartButton_pressed():
	var failed = get_tree().change_scene("res://Scenes/Opening_scene.tscn")                                                     
	if failed:
		print("Failed scene transition.")

func _on_QuitButton_pressed():
	get_tree().quit()
