extends PlayerState

const DRAG_SMOOTHING = 25.0 # Higher = snappier, Lower = floatier 
const ROTATION_SENSITIVITY = 0.8
const SWAY_SPEED = 15.0
const MAX_SWAY_ANGLE = 25.0
const RECOVERY_SPEED = 8.0

var current_trash: TrashShape
#var original_slot: Control
#var ui_container: Container
var is_valid_drop: bool
var current_grid_pos := Vector2i.ZERO

var current_sway := 0.0

func enter(previous_state_path: String, data := {}) -> void:
	## uncomment WHEN you want an inventory system
	#if data.has("slot_node"): 
		#original_slot = data["slot_node"]
		#current_trash = original_slot.item_data
		#ui_container = original_slot.get_parent()
		#original_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if data.has("trash"):
		current_trash = data["trash"]
	
	# initial setup
	level.ghost_cursor.visible = false
	_update_ghost_visual()
	level.held_visual.visible = true
	level.held_visual.setup(current_trash)
	level.held_visual.global_position = level.get_global_mouse_position()
	current_sway = 0.0
	level.held_visual.rotation_degrees = 0.0
	
	print("State: Dragging")

func exit() -> void:
	level.ghost_cursor.visible = false
	level.held_visual.visible = false
	current_trash = null

func update(delta: float) -> void:
	_process_sway_physics(delta)
	#_handle_inventory_reordering()

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
		else:
			level.ghost_cursor.visible = false
			level.held_visual.visible = true
	
	if _event.is_action_pressed("rotate_item"): # Rotate
		current_trash.rotate()
		_update_ghost_visual()         
		_validate_position()
		
		get_viewport().set_input_as_handled()
	
	elif _event.is_action_pressed("place_item") or (_event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT and not _event.pressed):
		_validate_position()
		if is_valid_drop:
			level.grid_system.place_item(current_grid_pos, current_trash)
			#if original_slot: original_slot.consume_item()
			finished.emit("Idle") 
		else:
			_stop_dragging()
	
	elif _event.is_action_pressed("ui_cancel"): # Cancel
		_stop_dragging()

## FEATURE: i comment this so that we can use it when needed later
#func _handle_inventory_reordering():
	#if not original_slot or not ui_container: return
	#
	#var local_mouse = ui_container.get_local_mouse_position()
	#
	## Only run logic if mouse is roughly inside the inventory area
	#if abs(local_mouse.y) > 300:
		#return
#
	## Loop through all slots to check for swapping
	#var my_index = original_slot.get_index()
	#
	## Check Right Neighbor
	#if my_index < ui_container.get_child_count() - 1:
		#var right_neighbor = ui_container.get_child(my_index + 1)
		#if local_mouse.x > right_neighbor.position.x + (right_neighbor.size.x / 2.0):
			#ui_container.move_child(original_slot, my_index + 1)
			#return
#
	## Check Left Neighbor
	#if my_index > 0:
		#var left_neighbor = ui_container.get_child(my_index - 1)
		#if local_mouse.x < left_neighbor.position.x + (left_neighbor.size.x / 2.0):
			#ui_container.move_child(original_slot, my_index - 1)
			#return

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
	level.held_visual.rotation_degrees = current_trash.get_rotation() + current_sway
	
	# SEND JUICE DATA TO VISUAL
	level.held_visual.apply_swaying_effect(diff_vector, delta)

func _stop_dragging():
	level.grid_system.place_item(current_trash.get_last_origin(), current_trash)
	
	finished.emit("Idle")

## uncomment this WHEN you want an inventory feature
#func _stop_dragging():
	#if ui_container == null:
		#level.add_item(original_slot)
		#
	#if original_slot:
		#original_slot.show_item() # Make the icon visible again
		#original_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	#finished.emit("Idle") 
