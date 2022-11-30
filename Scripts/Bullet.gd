extends Area2D

var die_size : int = 4
var base_speed : int
var damage : int = 1

var speed : int

onready var world = get_parent()

#TRAIL STATS
#var trail_length = 30
#var point : Vector2
#onready var trail_scene = preload("res://Scenes/PlayerTrail.tscn")
#var trail_instance

func _ready():
	#$Sprite = dice_size
	speed = base_speed + damage * 20
	#$Polygon2D.scale = Vector2(2, 2) * (0.5 + damage * 0.05)
	#$Sprite.scale = Vector2(2, 2) * (0.5 + damage * 0.1)
	#$CollisionShape2D.scale = Vector2(2, 2) * (0.5 + damage * 0.1)
	
#	# TRAIL
#	trail_instance = trail_scene.instance()
#	trail_instance.trail_length = 40
#	trail_instance.width = 3
#	trail_instance.target_trail = $Trail_pos
#	world.add_child(trail_instance)
	

func _physics_process(delta):
	var movement = transform.x * speed * delta
	position += movement
#	position.y += grav_mod
	speed -= speed * delta
	if speed <= 0:
		#trail_instance.queue_free()
		queue_free()


func _on_Bullet_body_entered(body):
	if !body.is_in_group("shot"):
		if speed <= base_speed - 20: # checks to see if bullet just fired
			if body.is_in_group("player"):
				body.take_damage(1)
				#trail_instance.queue_free()
				queue_free()
		if body.is_in_group("enemy") and !body.is_in_group("aura"):
			body.take_damage(damage)
			if damage < die_size:
				#trail_instance.queue_free()
				queue_free()



