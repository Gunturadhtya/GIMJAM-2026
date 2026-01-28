extends PlayerState

var current_grid_pos := Vector2i.ZERO

func enter(_previous_state_path: String, _data := {}) -> void:
	print("State: Idle")

func handle_input(_event: InputEvent):
	if _event is InputEventMouseMotion:
		var mouse_pos = level.get_global_mouse_position()
		var local_mouse = level.grid_system.tile_map.to_local(mouse_pos)
		current_grid_pos = level.grid_system.tile_map.local_to_map(local_mouse)
	
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT and _event.pressed:
		_handle_click()

func _handle_click():
	var selected_item = level.grid_system.get_item(current_grid_pos)
	
	if selected_item != null:
		level.current_trash_count -= 1
		print("Picked up item")
		finished.emit("Dragging", {"trash" : selected_item})
	else:
		print("Clicked empty space")
