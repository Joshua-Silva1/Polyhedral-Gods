extends AudioStreamPlayer2D

var sound : AudioStream
var pitch : float
var vol : float
var start_pos : float


func _ready():
	if sound != null and pitch != null and vol != null:
		soundFX(pitch, sound, vol, self, start_pos)

func soundFX(sound_pitch, sound_stream, vol_boost, sound_player, pos):
	if settings.fx_enabled:
		if sound_player.get_stream() != sound_stream:
			sound_player.set_stream(sound_stream)
		sound_player.volume_db = settings.fx_volume + vol_boost
		sound_player.pitch_scale = sound_pitch
		sound_player.play(pos)
		
		# DELETE AFTERWARDS
		yield(self, "finished")
		queue_free()
