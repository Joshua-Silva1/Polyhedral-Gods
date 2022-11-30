extends KinematicBody2D

onready var death_particles = preload("res://Scenes/Particles/ExplosionParticles.tscn")

onready var world = get_parent().get_parent()
onready var player = world.get_node("Player")

# STATS
var gravity : float = 50 # 50

var speed : int = 6000
var die_size : int = 4
var damage : int = 1
var hp : int = die_size

var max_boost : float
var boost : float = 1 # gives enemies boosts of speed at set intervals
var boost_time : float
var dice_factor : float

var roll : int
var dice_sprite : Texture

var direction : Vector2 = Vector2.ZERO
var aura_radius : float = 0

var buffed : bool = false

onready var boost_hum_sound = preload("res://Assets/Sounds/Hum.wav")
onready var pop_sound = preload("res://Assets/Sounds/Pop.wav")
onready var one_time_sound = preload("res://Scenes/One_Time_Sound.tscn")

func _ready():
	match die_size:
		4:
			$Sprite.frame = 6
			$CollisionPolygon2D.polygon = PoolVector2Array([Vector2(-5, -8), Vector2(9, 0), Vector2(-5, 8)])
		6:
			$Sprite.frame = 7
			$CollisionPolygon2D.polygon = PoolVector2Array([Vector2(-11, -11), Vector2(11, -11), Vector2(11, 11), Vector2(-11, 11)])
		8:
			$Sprite.frame = 8
			$CollisionPolygon2D.polygon = PoolVector2Array([Vector2(1, -13), Vector2(17, 0), Vector2(1, 13), Vector2(-17, 0)])
			aura_radius = 20
			$Hitbox/Sprite.modulate = Color("2aee8695")
		10:
			$Sprite.frame = 9
			$CollisionPolygon2D.polygon = PoolVector2Array([Vector2(-2, -16), Vector2(14, 0), Vector2(-2, 16), Vector2(-14, 0)])
			aura_radius = 32
			$Hitbox/Sprite.modulate = Color("52fbbbad")
		12:
			$Sprite.frame = 10
			$CollisionPolygon2D.polygon = PoolVector2Array([Vector2(12, -9), Vector2(14, 0), Vector2(12, 9), Vector2(-4, 14), Vector2(-14, 0), Vector2(-4, -14)])
	
	# STATS
	dice_factor = (float(die_size - 4) / 2)
	max_boost = 20 / float(die_size) # 10
	boost_time = clamp((13 - float(die_size)) / 4, 0.6, 1.8) # 13
	
	roll = randi() % die_size + 1
	dice_sprite = load("res://Assets/Sprites/D" + str(die_size) + "_Sprite.png")

	damage = int(round(float(roll) / 2))
	hp = roll
	scale += (Vector2(roll, roll) * 0.1 * clamp(dice_factor, 1, 20))
	speed += (800 - (dice_factor * 600) - (roll * 50))
	
	$Hitbox/CollisionShape2D.shape.radius = aura_radius
	$Hitbox/Sprite.scale = Vector2((aura_radius / 16), (aura_radius / 16))
	
	activate_boost()
	soundFX(1, boost_hum_sound, 5, $AudioStreamPlayer2D)

func _physics_process(delta):
	modulate = Color(1.3, 1.1, 1.1, 0.7) + Color(boost * (dice_factor + 1), boost * 0.2, boost * 0.2, boost * 0.2)
	
	#$Hitbox/CollisionShape2D.shape.radius = aura_radius * boost
	
	if aura_radius > 0:#if die_size == 8 or die_size == 10:#aura_radius > 0:
		$Hitbox/Sprite.scale = Vector2(0.0625, 0.0625) * aura_radius * boost
		$Hitbox/CollisionShape2D.shape.radius = aura_radius * boost
		#var new_rad = (1/16) * aura_radius * boost
		#$Hitbox/Sprite.scale = Vector2(new_rad, new_rad)
		
	# GET DIRECTION
	direction = position.direction_to(player.global_position)
	look_at(player.global_position)
	
	# Gravity
	direction.y += (gravity * delta) / (boost * 1.2)
	
	# MOVE
	direction.x *= 1.3
	direction = move_and_slide(speed * direction * delta * boost)
	
	# Crash if it hits the ground
	if position.y >= world.map_size.y:
		die(0)
	
	# SOUND
	$AudioStreamPlayer2D.pitch_scale = 0.7 + (boost/ 10)
	
	# PLAYER COLLISION
	var collision : KinematicCollision2D
	if get_slide_count() > 1:
		collision = get_slide_collision(1)
	elif get_slide_count() > 0:
		collision = get_slide_collision(0)
	if collision and collision.collider.is_in_group("player"):
		collision.collider.take_damage(damage)
		die(0)

func activate_boost():
	while hp > 0:
		$BoostTween.interpolate_property(self, "boost", 0.7, max_boost, boost_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$BoostTween.start()
		yield($BoostTween, "tween_completed")
		
		boost_ability()
		
		$BoostTween.interpolate_property(self, "boost", max_boost, 0.7, boost_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$BoostTween.start()
		yield($BoostTween, "tween_completed")

func boost_ability():
	match die_size:
		8:
			pass
		10:
			pass
		12:
			if roll > 6: # d12s spawn d4s
				var spawner = world.get_node("Enemy Spawner")
				var dir = direction.rotated(rand_range(-1, 1)) * 3
				spawner.unique_enemy_spawn(0, global_position, dir)

func take_damage(num):
	var prev_col = $Sprite.modulate
	$Tween.interpolate_property($Sprite, "modulate", Color.white, prev_col, 0.05, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	hp -= num
	if hp <= 0:
		die(1)
	else:
		scale -= Vector2(num, num) * 0.1 * dice_factor
		speed += num * 50
		explosion_particles(damage * 2)
		pop_sound_effect(5)
		$AudioStreamPlayer2D.pitch_scale = 1.7
	
	if num < 0:
		buffed = true

func die(score_multiplier):
	world.add_score(50 * int(round(float(roll + dice_factor/ 2))) * score_multiplier)
	# particles
	explosion_particles(25)
	
	# sounds
	pop_sound_effect(15)
	
	queue_free()

func pop_sound_effect(v):
	var s = one_time_sound.instance()
	s.pitch = 0.4
	s.sound = pop_sound
	s.vol = v
	s.position = global_position
	s.start_pos = 0.06
	
	world.add_child(s)

func explosion_particles(particle_amount):
	var p = death_particles.instance()
	p.texture = dice_sprite
	p.amount = particle_amount
	p.modulate = $Sprite.modulate
	p.position = global_position
	p.scale = Vector2(1, 1) * ((dice_factor + 4) / 4)
	world.add_child(p)

func soundFX(pitch, sound, vol_boost, sound_player):
	if settings.fx_enabled:
		if sound_player.get_stream() != sound:
			sound_player.set_stream(sound)
		sound_player.volume_db = settings.fx_volume + vol_boost
		sound_player.pitch_scale = pitch
		sound_player.play()

func _on_Hitbox_body_entered(_body) -> void:
	if die_size == 8:
		if _body.is_in_group("enemy"):
			if !_body.buffed:
				_body.take_damage(-1)


func _on_Hitbox_area_entered(_area):
	if die_size == 10:
		if _area.is_in_group("shot"):
			if _area.damage < _area.die_size:
				_area.queue_free()
