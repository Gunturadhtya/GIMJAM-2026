extends Control

@onready var animation_player = $AnimationPlayer
@onready var start_button = $Content/VBoxContainer2/VBoxContainer/Start
@onready var quit_button = $Content/VBoxContainer2/VBoxContainer/Quit
@onready var transition_overlay = $TransitionLayer/TransitionOverlay

# The scene you want to load
@export_file("*.tscn") var start_scene_path: String

func _ready():
	transition_overlay.visible = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	animation_player.play("fade_in")
	
	await animation_player.animation_finished
	AudioManager.play_bgm(load("res://Assets/Music/Tidy Up Sad.mp3"))

func _on_start_pressed():
	AudioManager.play_sfx(load("res://Assets/sfx/Click_SFX_New.mp3"))
	set_process_input(false) 
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(start_scene_path)

func _on_quit_pressed():
	AudioManager.play_sfx(load("res://Assets/sfx/Click_SFX_New.mp3"))
	set_process_input(false) 
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().quit()
