class_name LevelManager extends Node2D

@export_group("Systems")
@export var grid_system: GridSystem
@export var state_machine: StateMachine

@export_group("Level Data")
@export var stage_data: StageData
	
@onready var ui = $CanvasLayer/LevelUI 
@onready var animation_player = $AnimationPlayer
@onready var transition_overlay = $TransitionLayer/TransitionOverlay
@onready var dialogue = $CanvasLayer/LevelUI/Dialogue

var current_trash_count: int = 0

func _ready() -> void:
	# Initialize UI via the new UI controller
	Global.is_dialogue_active = false
	if ui:
		ui.setup(stage_data)
	
	current_trash_count = stage_data.trash_goal
	
	grid_system.grid_updated.connect(_on_path_changed)
	dialogue.dialogue_finished.connect(_on_cutscene_ended)
	
	transition_overlay.visible = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	animation_player.play("fade_in")

func _on_path_changed():
	_check_win_condition()

func _check_win_condition():
	print("on win ", current_trash_count)
	if current_trash_count == stage_data.trash_goal and grid_system.check_path():
		Global.is_dialogue_active = true
		dialogue.start_sequence(stage_data.dialogue)

func _handle_win():
	print("You Win!")
	
	await get_tree().create_timer(1.0).timeout
	
	set_process_input(false) 
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(stage_data.next_scene)

func _on_cutscene_ended():
	_handle_win()
