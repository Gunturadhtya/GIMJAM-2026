extends Control

@onready var animation_player = $AnimationPlayer
@onready var start_button = $Content/VBoxContainer2/VBoxContainer/Start
@onready var transition_overlay = $TransitionOverlay

# The scene you want to load
@export_file("*.tscn") var start_scene_path: String

func _ready():
	transition_overlay.visible = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_button.pressed.connect(_on_start_pressed)
	animation_player.play("fade_in")

func _on_start_pressed():
	set_process_input(false) 
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(start_scene_path)
