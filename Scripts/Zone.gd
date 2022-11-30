extends Area2D

#var type

func _on_ZoneTimer_timeout():
	#undo zone effects
	queue_free()
