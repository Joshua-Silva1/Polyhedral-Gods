extends Timer
#
#export var zone = preload("res://Scenes/Zone.tscn")
#
#onready var zones = get_parent().get_node("Zones") # YSORT PARENT NODE
#
#var current_zone_count : int = 0
#var max_zones : int = 1
#var count : int = 0  # for progressive increase
#
#func _ready():
#	randomize()
#	spawn_zones()

func _on_Zone_Spawner_timeout():
	pass
#	spawn_zones()
#	count += 1
#	max_zones = 1 + (count / 2)

#func spawn_zones():
#	while current_zone_count < max_zones:
#		current_zone_count += 1
#
#		var z = zone.instance()
#
#		# ZONE STATS
#		var max_duration = int(25 / current_zone_count)
#		z.get_node("ZoneTimer").wait_time = randi() % max_duration + 5
#
#		var zone_scale = rand_range(2.5, 8)
#		z.scale = Vector2(zone_scale, zone_scale)
#		var radius = 32 * zone_scale
#
#		z.position.x = rand_range(-1100 + radius, 1100 - radius)
#		z.position.y = rand_range(-600 + radius, 610 - radius)
#
#		zones.add_child(z)
