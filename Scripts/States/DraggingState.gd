extends PlayerState

@export_group("Visual References")
@export var ghost_cursor: Node2D 
@export var held_visual: Node2D 

@export_group("Settings")
@export var drag_smoothing: float = 25.0
@export var rotation_sensitivity: float = 0.8
@export var sway_speed: float = 15.0
@export var max_sway_angle: float = 25.0
@export var recovery_speed: float = 8.0

var current_trash: TrashShape
var is_valid_drop: bool
var current_grid_pos := Vector2i.ZERO
var current_sway := 0.0

func enter(_previous_state_path: String, data := {}) -> void:
	if data.has("trash"):
		current_trash = data["trash"]
	
	ghost_cursor.visible = false
	_update_ghost_visual()
	
	held_visual.visible = true
	held_visual.setup(current_trash)
	held_visual.global_position = level.get_global_mouse_position()
	held_visual.rotation_degrees = 0.0
	
	current_sway = 0.0
	print("State: Dragging")

func exit() -> void:
	ghost_cursor.visible = false
	held_visual.visible = false
	current_trash = null

func update(delta: float) -> void:
	_process_sway_physics(delta)

func handle_input(_event: InputEvent) -> void:
	if _event is InputEventMouseMotion:
		_update_mouse_position()
	
	elif _event.is_action_pressed("rotate_item"):
		current_trash.rotate()
		_update_ghost_visual()      
		_validate_position()
		get_viewport().set_input_as_handled()
	
	elif _event.is_action_pressed("place_item") or (_event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT and not _event.pressed):
		_attempt_place_item()
	
	elif _event.is_action_pressed("ui_cancel"):
		_stop_dragging()

# --- HELPER FUNCTIONS ---

func _update_mouse_position():
	var mouse_pos = level.get_global_mouse_position()
	var local_mouse = level.grid_system.tile_map.to_local(mouse_pos)
	current_grid_pos = level.grid_system.tile_map.local_to_map(local_mouse)
	
	var ghost_local = level.grid_system.tile_map.map_to_local(current_grid_pos)
	
	ghost_cursor.global_position = level.grid_system.tile_map.to_global(ghost_local)
	
	_validate_position()
	
	ghost_cursor.visible = is_valid_drop

func _attempt_place_item():
	_validate_position()
	if is_valid_drop:
		level.grid_system.place_item(current_grid_pos, current_trash)
		level.current_trash_count += 1
		finished.emit("Idle") 
	else:
		_stop_dragging()

func _stop_dragging():
	level.grid_system.place_item(current_trash.get_last_origin(), current_trash)
	level.current_trash_count += 1
	finished.emit("Idle")

func _update_ghost_visual():
	ghost_cursor.update_visuals(current_trash)

func _validate_position():
	is_valid_drop = level.grid_system.is_area_valid(current_grid_pos, current_trash.offset)
	ghost_cursor.set_color_status(is_valid_drop)

func _process_sway_physics(delta): 
	var mouse_pos = level.get_global_mouse_position()
	
	# POSITION
	var current_pos = held_visual.global_position
	var new_pos = current_pos.lerp(mouse_pos, delta * drag_smoothing)
	held_visual.global_position = new_pos
	
	# SWAY
	var diff_vector = mouse_pos - new_pos
	var target_angle_offset = clamp(diff_vector.x * -rotation_sensitivity, -max_sway_angle, max_sway_angle)
	current_sway = lerp(current_sway, target_angle_offset, delta * recovery_speed)
	
	# Apply Rotation
	held_visual.rotation_degrees = current_trash.get_rotation() + current_sway
	
	held_visual.apply_swaying_effect(diff_vector, delta)
