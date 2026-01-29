extends Node

var bgm_player: AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Music"

func play_bgm(stream: AudioStream):
	if bgm_player.stream == stream and bgm_player.playing:
		bgm_player.stop()
	bgm_player.stream = stream
	bgm_player.play()

## SFX Logic
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if stream == null:
		return

	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = pitch_scale
	sfx_player.bus = "SFX"
	
	sfx_player.finished.connect(sfx_player.queue_free)
	
	sfx_player.play()

func play_voice_blip(stream: AudioStream, pitch: float = 1.0):
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.stream = stream
	p.pitch_scale = pitch
	p.bus = "SFX"
	p.finished.connect(p.queue_free)
	p.play()

func play_take_sfx(stream: AudioStream):
	play_sfx(stream, 0.0, 1.1) 

func play_rotate_sfx(stream: AudioStream):
	var random_pitch = randf_range(0.95, 1.05)
	play_sfx(stream, -2.0, random_pitch)

func play_place_sfx(stream: AudioStream):
	play_sfx(stream, 0.0, 0.9)

func stop_bgm():
	bgm_player.stop()
