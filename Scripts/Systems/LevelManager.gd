class_name LevelManager extends Node2D

@export_group("Systems")
@export var grid_system: GridSystem
@export var state_machine: StateMachine

@export_group("Level Data")
@export var stage_data: StageData
	
@onready var ui = $CanvasLayer/LevelUI 

var current_trash_count: int = 0

func _ready() -> void:
	# Initialize UI via the new UI controller
	if ui:
		ui.setup(stage_data)
	
	grid_system.grid_updated.connect(_on_path_changed)

func _on_path_changed():
	_check_win_condition()

func _check_win_condition():
	if current_trash_count == stage_data.trash_goal and grid_system.check_path():
		_handle_win()

func _handle_win():
	print("You Win!")
