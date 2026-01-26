extends PlayerState

const SWAY_SPEED = 15.0
const MAX_SWAY_ANGLE = 25.0
const RECOVERY_SPEED = 8.0

var current_trash: TrashShape
var is_valid_drop: bool
var current_grid_pos := Vector2i.ZERO
var rotated := 0

var last_mouse_x := 0.0
var current_sway := 0.0
var target_visual_rotation := 0.0 

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
	target_visual_rotation = 0.0
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
			level.held_visual.visible = false
		else:
			level.ghost_cursor.visible = false
			level.held_visual.visible = true
			
	
	if _event.is_action_pressed("rotate_item"): # Rotate
		current_trash.rotate()
		
		rotated = (rotated + 1) % 4 # modus 4 bcus the item only have 4 rotated state 0, 90, 180 and 270
		
		target_visual_rotation += 90.0 
		_update_ghost_visual()         
		_validate_position()
		
		get_viewport().set_input_as_handled()
	
	# if the button place item is pressed or if the mouse is released
	elif _event.is_action_pressed("place_item") or _event is InputEventMouseButton: 
		if _event.button_index == MOUSE_BUTTON_LEFT and not _event.pressed:
			if is_valid_drop:
				level.grid_system.place_item(current_grid_pos, current_trash, rotated)
				rotated = 0
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

func _process_sway_physics(delta): # this is the logic behind held item swaying
	var mouse_pos = level.get_global_mouse_position()
	
	level.held_visual.global_position = mouse_pos
	
	var velocity_x = mouse_pos.x - last_mouse_x
	
	var target_tilt = clamp(-velocity_x * SWAY_SPEED * delta, -MAX_SWAY_ANGLE, MAX_SWAY_ANGLE)
	
	current_sway = lerp(current_sway, target_tilt, delta * RECOVERY_SPEED)
	
	level.held_visual.rotation_degrees = target_visual_rotation + current_sway
	
	last_mouse_x = mouse_pos.x

func _stop_dragging():
	level.add_item(current_trash)
	rotated = 0
	finished.emit("Idle") 
