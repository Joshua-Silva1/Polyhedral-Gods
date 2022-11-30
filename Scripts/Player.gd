extends KinematicBody2D

export var bullet : PackedScene = preload("res://Scenes/Bullet.tscn")

onready var world = get_parent()
onready var HUD = world.get_node("HUD")

# CHARACTER STATS
onready var air_resistance : int = 800 #200
onready var base_bullet_speed = 300
onready var heavy_dice : int = 8
#var light_dice
onready var base_thrust = 200
onready var magazine_size : int = 5
onready var reload_speed : float = 0.12
onready var charge_speed : float = 0.1
onready var min_shot_cooldown : float = 0.1
#
onready var gravity : int = 350
onready var terminal_velocity : float = 1500

# ACTIVE STATS
onready var hp : int = heavy_dice
onready var velocity : Vector2 = Vector2.ZERO
onready var magazine : Array = []
onready var braced : bool = false
onready var reloading : bool = false
onready var charging : bool = false
onready var shot_ready : bool = true
onready var gameover : bool = false
onready var grapple_deployed : bool = false

onready var dice_sprite : Texture
onready var prev_col = $Body/Sprite.modulate
onready var player_trail = world.get_node("PlayerTrail")

# SOUNDS
onready var roll_dice_sound = preload("res://Assets/Sounds/Roll_dice.wav")
onready var reload_sound = preload("res://Assets/Sounds/Reload.wav")
onready var exploding_dice_sound = preload("res://Assets/Sounds/Exploding_dice.wav")
onready var charge_sound = preload("res://Assets/Sounds/Charge.wav")
onready var wind_sound = preload("res://Assets/Sounds/Wind.wav")
onready var death_chord = preload("res://Assets/Sounds/Death_chord.wav")

# PARTICLES
onready var reload_particles = preload("res://Scenes/Particles/ReloadParticles.tscn")

onready var one_time_sound = preload("res://Scenes/One_Time_Sound.tscn")

func _ready():
	randomize()
	$ReloadTimer.wait_time = reload_speed
	$ShotCooldownTimer.wait_time = reload_speed / 2

	$DiceFace.text = str(hp)
	dice_sprite = load("res://Assets/Sprites/D" + str(heavy_dice) + "_Sprite.png")
	reload()

	soundFX(1, wind_sound, -20, $SOUNDS/Wind)
	$Body.scale += Vector2(hp, hp) * 0.05
	$CollisionPolygon2D.scale += Vector2(hp, hp) * 0.05

	$CollisionPolygon2D.polygon = $CollisionPolygon2D.polygon
	$Bounce.scale = $Body.scale + Vector2(0.1, 0.1)

func _process(delta : float) -> void:
	# Rotation to look at cursor
	var mouse_pos = get_global_mouse_position()
	$Body.look_at(mouse_pos)
	$CollisionPolygon2D.look_at(mouse_pos)
	$Bounce.look_at(mouse_pos)
	#look_at(mouse_pos)

	# Movement
		# Horizontal + Air Resistance
	if !gameover:
		get_input() # also checks for shoot

	var AR = 1
	if braced:
		AR = 4

			# Gravity
	if velocity.y < terminal_velocity:
		velocity.y += gravity * delta

	$SOUNDS/Wind.pitch_scale = (velocity.length() / terminal_velocity) * 1.5

	if abs(velocity.x) > 2:
		velocity.x /= (1 + delta * AR)
	if abs(velocity.y) > 2:
		velocity.y /= (1 + delta * AR)

	# Charging shots
	while charging and $ChargeTimer.is_stopped() and !reloading:
		var count : int = 1
		for i in magazine_size:
			if magazine[i] <= heavy_dice:
				count += i
				break
		var t = charge_speed * pow(count, 2)
		$ChargeTimer.start(t)

	velocity = move_and_slide(velocity) #, Vector2.UP)

	# Taking damage + Destroying Enemies on Collision
	var collision : KinematicCollision2D
	if get_slide_count() > 1:
		collision = get_slide_collision(1)
	elif get_slide_count() > 0:
		collision = get_slide_collision(0)
	if collision and collision.collider.is_in_group("enemy"):
		take_damage(collision.collider.damage)
		collision.collider.die(0)

	# Camera Offset
	$Camera2D.offset_h = (mouse_pos.x - global_position.x) / 512
	$Camera2D.offset_v = (mouse_pos.y - global_position.y) / 300


func get_input():
	if Input.is_action_pressed("left_click"):
		if !reloading and shot_ready:
			shoot()

	if Input.is_action_pressed("right_click"):
		if !grapple_deployed:
			shoot()

	if Input.is_action_pressed("brace"):
		set_braced(true)#braced = true
	elif Input.is_action_just_released("brace"):
		set_braced(false)#braced = false
		reload()
	else:
		if braced:
			set_braced(false)#braced = false

	if Input.is_action_pressed("charge"):
		charging = true
	elif Input.is_action_just_released("charge"):
		charging = false
	else:
		if charging:
			charging = false

	# Break out of current action when new button is pressed
	if Input.is_action_just_pressed("charge"):
		charging = true
		set_braced(false)#braced = false
	elif Input.is_action_just_pressed("brace"):
		set_braced(true)#braced = true
		charging = false


func set_braced(i):
	if !braced and i:
		$AnimationPlayer.play("Focus Line")
	if braced and !i:
		$Body/Sprite.modulate = prev_col

	braced = i
	$Body/Line2D.visible = i
	
	
	
	if braced:
		player_trail.default_color = Color("afd96a51")
	else:
		player_trail.default_color = Color("affbbbad")
		#$AnimationPlayer.play("Cool_down")
		#$Body/Sprite.modulate = prev_col
#	if braced:
#		#soundFX(1, "", 0, $SOUNDS/Charge)
#		$Body/BracedParticles.emitting = true
#	else:
#		$SOUNDS/Charge.stop()
#		$Body/BracedParticles.emitting = false

func shoot():
	if magazine.size() > 0 and !reloading: # and shot_ready:
		var spray_angle : float
		if braced:
			spray_angle = 0
		else:
			spray_angle = rand_range(-0.15, 0.15)

		shot_ready = false
		charging = false

		inst_bullet(spray_angle, magazine.front(), 1)
		magazine.pop_front()

		var rand_pitch = rand_range(0.8, 1.1)
		soundFX(rand_pitch, roll_dice_sound, 0, $SOUNDS/Shot)

		reload()
		$ShotCooldownTimer.start()

		if braced:
			update_mag()
	else:
		# empty mag sound (click)
		pass
	if magazine.size() == 0:
		reload()

func grapple():
	pass

func reload():
	# CONDITIONS
	if braced and magazine.size() > 0:
		return
	if magazine.size() == magazine_size:
		return

	## -- FUNCTIONALITY -- ##
	reloading = true

	# SOUND
	soundFX(0.5, reload_sound, 0, $SOUNDS/Reload)

	# GETTING RELOAD TIME
	var r_duration : float #= reload_speed
	if braced:
		r_duration = ((float(magazine_size) - magazine.size()) / float(magazine_size)) + reload_speed * 1.5
	else:
		r_duration = ((float(magazine_size) - magazine.size()) / float(magazine_size)) + reload_speed
	$ReloadTimer.start(r_duration)

	# RELOAD MECHANICS - roll new bullets - #
	var empty_count : int = 0 # amount of empty bullets
	while magazine.size() < magazine_size:
		var bullet_dmg_roll : int = 1 + randi() % heavy_dice
		magazine.append(bullet_dmg_roll)
		empty_count += 1

	# PARTICLES
	var r_p = reload_particles.instance()
	r_p.position = global_position
	r_p.texture = dice_sprite
	r_p.amount = clamp(empty_count, 1, magazine_size)
	world.call_deferred("add_child", r_p)

	yield($ReloadTimer, "timeout")
	$SOUNDS/Reload.stop()

	# HUD UPDATE
	update_labels()

	reloading = false

func inst_bullet(angle, dmg_roll, count):
	# INSTANCING BULLET + SETTING STATS
	var b = bullet.instance()
	b.base_speed = base_bullet_speed
	if braced:
		b.base_speed *= 1.5
	b.die_size = heavy_dice
	if !dmg_roll:
		dmg_roll = 1
	b.damage = dmg_roll


	#b.dice_size = heavy_dice

	# CHECKING EXPLOSIONS
	var explode_count : int = count
	if dmg_roll == heavy_dice:
		b.base_speed += base_bullet_speed # double speed of exploded bullets
		explode_dice(explode_count + 1)


	b.transform = $Body/Muzzle.global_transform.rotated(angle)
	b.transform.origin = $Body/Muzzle.global_transform.origin

	b.scale += Vector2(0.1, 0.1) * dmg_roll

	world.add_child(b)
	recoil(explode_count)

func recoil(explode_count):
	var recoil_b = (heavy_dice * 40 + base_thrust) / (explode_count)
	if braced:
		recoil_b /= 1.5
	velocity -= Vector2(recoil_b, recoil_b) * position.direction_to(get_global_mouse_position())

	 # lessen downward recoil
	if velocity.y > 0:
		velocity.y /= 2

func charge_shots():
	for i in magazine.size():#magazine_size:
		if charging:
			if magazine[i] < heavy_dice:
				soundFX(1, charge_sound, 0, $SOUNDS/Charge)
				magazine[i] += 1
				update_mag()
				break

func explode_dice(explode_count):
	match heavy_dice: # match with class ability
		4:
			pass
		6:
			pass
		8:
			var pitch = 0.9 + 0.08 * explode_count
			soundFX(pitch, exploding_dice_sound, 0, $SOUNDS/Explode)
			var angle = rand_range(-0.1, 0.1) * 10
			var roll = 1 + randi() % heavy_dice
			inst_bullet(angle, roll, explode_count)
		10:
			pass
		12:
			pass

func take_damage(num):
	$Tween.interpolate_property($Body/Sprite, "modulate", Color.white, prev_col, 0.02, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	hp -= num
	update_labels()
	if hp <= 0:
		# DEATH ANIMATION
		dead()
		world.gameover()

	$Body.scale -= Vector2(num, num) * 0.05
	$CollisionPolygon2D.scale -= Vector2(num, num) * 0.05
	gravity -= num * 30

	yield($Tween, "tween_completed")

	$Body/Sprite.modulate = prev_col

func dead():
	#particles / animation

	# sound
	if !gameover:
		var s = one_time_sound.instance()
		s.pitch = 1
		s.sound = death_chord
		s.vol = 25
		s.position = global_position
		s.start_pos = 0.02

		world.add_child(s)


	# Stats
	gravity = 0
	charging = false

	# hitboxes stop working
	set_deferred("Bounce/monitorable", false)
	set_deferred("Bounce/monitoring", false)
	set_deferred("Bounce/CollisionPolygon2D/disable", true)
	#set_deferred("Bounce/CollisionPolygon2D/monitoring", false)

	# player invisible
	visible = false
	# zoom out
	gameover = true

func update_labels():
	$DiceFace.text = str(hp)
	update_mag()

func update_mag():
	HUD.get_node("Labels").update_mags(magazine)

func soundFX(pitch, sound, vol_boost, sound_player):
	if settings.fx_enabled:
		if sound_player.get_stream() != sound:
			sound_player.set_stream(sound)
		sound_player.volume_db = settings.fx_volume + vol_boost
		sound_player.pitch_scale = pitch
		sound_player.play()

func _on_Bounce_body_entered(body):
	if body.is_in_group("wall"):
		velocity = position.direction_to(world.map_size / 2) * 700#position.direction_to(body.position) * 500
		take_damage(1)

func _on_ChargeTimer_timeout():
	charge_shots()

func _on_ShotCooldownTimer_timeout():
	shot_ready = true
