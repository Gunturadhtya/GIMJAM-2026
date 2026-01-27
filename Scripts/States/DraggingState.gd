extends PlayerState

const DRAG_SMOOTHING = 25.0 # Higher = snappier, Lower = floatier 
const ROTATION_SENSITIVITY = 0.8
const SWAY_SPEED = 15.0
const MAX_SWAY_ANGLE = 25.0
const RECOVERY_SPEED = 8.0

var current_trash: TrashShape
var is_valid_drop: bool
var current_grid_pos := Vector2i.ZERO

var last_mouse_x := 0.0
var current_sway := 0.0

func enter(previous_state_path: String, data := {}) -> void:
	if data.has("trash"):
		current_trash = data["trash"]
	
	# initial setup
	level.ghost_cursor.visible = false
	_update_ghost_visual()
	level.held_visual.visible = true
	level.held_visual.setup(current_trash)
	last_mouse_x = level.get_global_mouse_position().x
	current_sway = 0.0
	level.held_visual.rotation_degrees = 0.0
	
	print("State: Dragging")

func exit() -> void:
	level.ghost_cursor.visible = false
	level.held_visual.visible = false
	current_trash = null

func update(delta: float) -> void:
	_process_sway_physics(delta)

func handle_input(_event: InputEvent) -> void:
	if _event is InputEventMouseMotion: # Read the Mouse Position and Translate it into Tile Coords 
		var mouse_pos = level.get_global_mouse_position()
		var local_mouse = level.tile_map.to_local(mouse_pos)
		current_grid_pos = level.tile_map.local_to_map(local_mouse)
		
		var ghost_local = level.tile_map.map_to_local(current_grid_pos)
		level.ghost_cursor.global_position = level.tile_map.to_global(ghost_local)
		
		_validate_position()
		
		if is_valid_drop:
			level.ghost_cursor.visible = true
			level.held_visual.visible = true  
			level.ghost_cursor.modulate.a = 0.5 
		else:
			level.ghost_cursor.visible = false
			level.held_visual.visible = true
			
	
	if _event.is_action_pressed("rotate_item"): # Rotate
		current_trash.rotate()
		_update_ghost_visual()         
		_validate_position()
		
		get_viewport().set_input_as_handled()
	
	# if the button place item is pressed or if the mouse is released
	elif _event.is_action_pressed("place_item") or _event is InputEventMouseButton: 
		if _event.button_index == MOUSE_BUTTON_LEFT and not _event.pressed:
			if is_valid_drop:
				level.grid_system.place_item(current_grid_pos, current_trash)
				finished.emit("Idle") 
			else:
				_stop_dragging()
	
	elif _event.is_action_pressed("ui_cancel"): # Cancel
		_stop_dragging()

func _update_ghost_visual():
	level.ghost_cursor.update_visuals(current_trash)

func _validate_position():
	is_valid_drop = level.grid_system.is_area_valid(current_grid_pos, current_trash.offset)
	level.ghost_cursor.set_color_status(is_valid_drop)

func _process_sway_physics(delta): 
	var mouse_pos = level.get_global_mouse_position()
	
	# POSITION LAG
	var current_pos = level.held_visual.global_position
	var new_pos = current_pos.lerp(mouse_pos, delta * DRAG_SMOOTHING)
	level.held_visual.global_position = new_pos
	
	# CALCULATE VELOCITY DIFFERENCE
	var diff_vector = mouse_pos - new_pos
	
	# ROTATIONAL SWAY
	var target_angle_offset = clamp(diff_vector.x * -ROTATION_SENSITIVITY, -MAX_SWAY_ANGLE, MAX_SWAY_ANGLE)
	
	# Smooth the rotation
	current_sway = lerp(current_sway, target_angle_offset, delta * RECOVERY_SPEED)
	
	# Apply Base Rotation
	level.held_visual.rotation_degrees = current_trash.rotated_degree + current_sway
	
	# SEND JUICE DATA TO VISUAL
	level.held_visual.apply_swaying_effect(diff_vector, delta)

func _stop_dragging():
	level.add_item(current_trash)
	finished.emit("Idle") 
