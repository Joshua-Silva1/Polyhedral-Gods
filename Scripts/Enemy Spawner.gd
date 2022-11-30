extends Timer

export var enemy = preload("res://Scenes/Enemy.tscn")

onready var world = get_parent()
onready var enemies = world.get_node("Enemies") # YSORT PARENT NODE

var game_time : float = 0
var spawn_time : int = 1
var current_enemies : int = 0
var max_enemies : float = 10
var enemy_types = [4, 6, 8, 10, 12, 20]

var phase_time : float = 15 # after each phase time, new enemies can join the fight

func _ready():
	randomize()
	current_enemies = enemies.get_child_count()
	wait_time = spawn_time
	start()

func _on_Enemy_Spawner_timeout():
	current_enemies = enemies.get_child_count()
	var spawn_rate : float = clamp(float(game_time) / 15, 1, 15) #clamp(round((float(game_time) / 15)), 1, 10)
	if current_enemies < max_enemies:
		for x in (randi() % int(spawn_rate) + 1):
			spawn_enemy()
	game_time += 1
	if game_time == phase_time:
		world.start_track(2)
	if game_time == phase_time * 2:
		world.start_track(3)
	
	max_enemies = clamp(5 + (game_time / 3), 5, 30)
	
	

func spawn_enemy():
	var e = enemy.instance()
	
	# GETTING ENEMY TYPE
	var highest_enemy_type = clamp(1 + (game_time / 10), 1, 4)
	var type = randi() % int(highest_enemy_type) # 0 # game_time/30
	
	# SETTING POS
	var vec = Vector2.ZERO
	vec.x = rand_range(-100, world.map_size.y + 100)
	
	vec.y = -500
	
	e.position = vec
	
	# ROLL STATS
	e.die_size = enemy_types[type]
	
	enemies.add_child(e)


func unique_enemy_spawn(type, pos, dir):
	if current_enemies < (max_enemies + 5):
		var e = enemy.instance()
		
		# SETTING POS
		e.position = pos
		e.direction = dir
		
		# ROLL STATS
		e.die_size = enemy_types[type]
		
		enemies.add_child(e)
