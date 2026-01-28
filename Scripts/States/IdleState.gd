extends PlayerState

var current_grid_pos

func enter(previous_state_path: String, data := {}) -> void:
	level.ghost_cursor.visible = false
	level.held_visual.visible = false
	print("State: Idle")

func handle_input(_event: InputEvent):
	if _event is InputEventMouseMotion: # Read the Mouse Position and Translate it into Tile Coords 
		var mouse_pos = level.get_global_mouse_position()
		var local_mouse = level.tile_map.to_local(mouse_pos)
		current_grid_pos = level.tile_map.local_to_map(local_mouse)
		
	
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT and _event.pressed:
		var selected_item = level.grid_system.get_item(current_grid_pos)
		print("Click")
		if selected_item != null:
			finished.emit("Dragging", {"trash" : selected_item})
	
	## DEBUG: for debugging only
	#if _event.is_action_pressed("ui_accept"):
		#level.add_random_item_to_inventory()
		#
		#get_viewport().set_input_as_handled()
