extends ColorRect



#onready var d8_sprite = preload("res://Assets/Sprites/D8_Sprite.png")

onready var world = get_parent().get_parent()
onready var player = world.get_node("Player")

var magazine : Array

func update_mags(mag):
	magazine = mag
	$Shot1.text = get_bullet_roll(0)
	$Shot2.text = get_bullet_roll(1)
	$Shot3.text = get_bullet_roll(2)
	$Shot4.text = get_bullet_roll(3)
	$Shot5.text = get_bullet_roll(4)
	
#	$Shot1.text = str(magazine[0])
#	$Shot2.text = str(magazine[1])
#	$Shot3.text = str(magazine[2])
#	$Shot4.text = str(magazine[3])
#	$Shot5.text = str(magazine[4])

func get_bullet_roll(i):
	if magazine.size() >= (i + 1):
		if i == 0:
			if magazine[i] == 8:
				$BigShotParticles.emitting = true
			else:
				$BigShotParticles.emitting = false
		return str(magazine[i])
	else:
		return "X"#str(0)

#	var mag_text
#	match magazine.size():
#		0:
#			mag_text = ""
#		1:
#			mag_text = "%s" % magazine
#		2:
#			mag_text = "%s %s" % magazine
#		3:
#			mag_text = "%s %s %s" % magazine
#		4:
#			mag_text = "%s %s %s %s" % magazine
#		5:
#			mag_text = "%s %s %s %s %s" % magazine
##		6:
##			mag_text = "%s %s %s %s %s %s" % magazine
##		7:
##			mag_text = "%s %s %s %s %s %s %s" % magazine
##		8:
##			mag_text = "%s %s %s %s %s %s %s %s" % magazine
##		9:
##			mag_text = "%s %s %s %s %s %s %s %s %s" % magazine
##		10:
##			mag_text = "%s %s %s %s %s %s %s %s %s %s" % magazine
##		11:
##			mag_text = "%s %s %s %s %s %s %s %s %s %s %s" % magazine
##		12:
##			mag_text = "%s %s %s %s %s %s %s %s %s %s %s %s" % magazine
#	$Magazine.text = mag_text
