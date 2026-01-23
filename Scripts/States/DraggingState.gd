extends PlayerState

var current_trash: TrashShape
var is_valid_drop: bool
var current_grid_pos := Vector2i.ZERO

func enter(previous_state_path: String, data := {}) -> void:
	if data.has("trash"):
		current_trash = data["trash"]
	
	level.ghost_cursor.visible = true
	_update_ghost_visual()
	print("State: Dragging")


func exit() -> void:
	level.ghost_cursor.visible = false
	current_trash = null


func handle_input(_event: InputEvent) -> void:
	if _event is InputEventMouseMotion:
		var mouse_pos = level.get_global_mouse_position()
		current_grid_pos = level.tile_map.local_to_map(mouse_pos)
		
		level.ghost_cursor.global_position = level.tile_map.map_to_local(current_grid_pos)
		_validate_position()
	
	if _event.is_action_pressed("rotate_item"):
		current_trash.rotate()
		_update_ghost_visual()
		_validate_position()
		
		get_viewport().set_input_as_handled()
	
	elif _event.is_action_pressed("place_item"):
		if is_valid_drop:
			level.grid_system.place_item(current_grid_pos, current_trash)
			finished.emit(IDLE)
		else:
			print("Position Invalid")
	
	elif _event.is_action_pressed("ui_cancel"):
		finished.emit(IDLE)

func _update_ghost_visual():
	level.ghost_cursor.update_visuals(current_trash.offset, current_trash.color)

func _validate_position():
	is_valid_drop = level.grid_system.is_area_valid(current_grid_pos, current_trash.offset)
	level.ghost_cursor.set_color_status(is_valid_drop)
