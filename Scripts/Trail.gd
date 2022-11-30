extends Line2D

export var trail_length = 50
var point : Vector2

onready var target_trail = get_parent().get_node("Player/Body/Trail_pos")

func _process(_delta):
	#global_position = Vector2(0, 0)
	#global_rotation = 0#player.global_rotation
	
	point = target_trail.global_position
	
	add_point(point)
	while get_point_count() > trail_length:
		remove_point(0)
