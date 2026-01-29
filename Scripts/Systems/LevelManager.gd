class_name Day2 extends LevelManager

@export var is_last_stage:bool

func _ready() -> void:
	Global.is_dialogue_active = false
	Global.is_cutscene_active = false
	
	cutscene_path.visible = false
	
	if ui:
		ui.setup(stage_data)
	
	current_trash_count = stage_data.trash_goal
	
	grid_system.grid_updated.connect(_on_path_changed)
	dialogue.dialogue_finished.connect(_on_dialogue_ended)
	cutscene_path.cutscene_finished.connect(_on_cutscene_ended)
	
	transition_overlay.visible = true
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	animation_player.play("fade_in")

func _on_path_changed():
	_check_win_condition()

func _check_win_condition():
	print("on win ", current_trash_count)
	if current_trash_count == stage_data.trash_goal and grid_system.check_path():
		ui.desc_label.visible = false
		
		player_tile.visible = false
		cutscene_path.visible = true
		
		var astar_path = grid_system.astar.get_point_path(grid_system.start_pos, grid_system.end_pos)
		
		cutscene_path.run_sequence(astar_path, path_ratio, go_back, stage_data.day)

func _handle_win():
	print("You Win!")

	set_process_input(false) 
	animation_player.play("fade_out")
	await animation_player.animation_finished
	_on_level_completed()

func _on_dialogue_ended():
	_handle_win()

func _on_cutscene_ended():
	Global.is_dialogue_active = true
	await get_tree().create_timer(1.0).timeout
	dialogue.start_sequence(stage_data.dialogue)

func _on_level_completed():
	if is_last_stage:
		SaveManager.current_level_id = 1
	else:
		SaveManager.current_level_id += 1
	
	SaveManager.save_game()
	get_tree().change_scene_to_file(stage_data.next_scene)
