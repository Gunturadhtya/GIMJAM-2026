extends Node

var bgm_player: AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Music"

func play_bgm(stream: AudioStream):
	if bgm_player.stream == stream and bgm_player.playing:
		return 
		
	bgm_player.stream = stream
	bgm_player.play()

func stop_bgm():
	bgm_player.stop()
