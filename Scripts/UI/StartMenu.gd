extends Control

@onready var animation_player = $AnimationPlayer
@onready var start_button = $Content/VBoxContainer2/VBoxContainer/Start
@onready var continue_button = $Content/VBoxContainer2/VBoxContainer/Continue
@onready var quit_button = $Content/VBoxContainer2/VBoxContainer/Quit
@onready var transition_overlay = $TransitionLayer/TransitionOverlay

const LEVEL_PATH_TEMPLATE = "res://Scene/Stages/Day%dStage.tscn"

func _ready():
	transition_overlay.visible = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	if SaveManager.has_save_file():
		continue_button.disabled = false
	else:
		continue_button.disabled = true
		continue_button.modulate.a = 0.5 
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	AudioManager.play_bgm(load("res://Assets/Music/Tidy Up Sad.mp3"))

func _on_start_pressed():
	AudioManager.play_sfx(load("res://Assets/sfx/Click_SFX_New.mp3"))
	set_process_input(false)
	
	SaveManager.reset_data()
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://Scene/Storytellling/Intro.tscn")

func _on_continue_pressed():
	AudioManager.play_sfx(load("res://Assets/sfx/Click_SFX_New.mp3"))
	set_process_input(false)
	
	SaveManager.load_game()
	
	_transition_to_level(SaveManager.current_level_id)

func _transition_to_level(level_id: int):
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	var level_path = LEVEL_PATH_TEMPLATE % level_id
	get_tree().change_scene_to_file(level_path)

func _on_quit_pressed():
	AudioManager.play_sfx(load("res://Assets/sfx/Click_SFX_New.mp3"))
	set_process_input(false) 
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().quit()
