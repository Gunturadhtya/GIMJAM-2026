class_name GridSystem extends Node

signal grid_updated

# --- Constants & Configuration ---
const TILE_ROTATIONS = [
	0,                                                                            # 0 deg
	TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H, # 90 deg
	TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,    # 180 deg
	TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V  # 270 deg
]

@export_group("Grid Settings")
@export var grid_size := Vector2i(8, 6)
@export var start_pos := Vector2i(1, 1)
@export var end_pos := Vector2i(7, 5)

@export_group("References")
@export var tile_map: TileMapLayer
@export var path_line: Line2D
@export var stage_data: StageData

# --- State ---
var astar := AStarGrid2D.new()

var occupied_cell: Dictionary[Vector2i, TrashShape]

# --- Lifecycle ---

func _ready() -> void:
	occupied_cell = stage_data.grid_content
	
	_setup_astar()
	reconstruct_grid_visuals()
	redraw_path()

func _setup_astar() -> void:
	astar.region = Rect2i(0, 0, grid_size.x, grid_size.y)
	astar.cell_size = Vector2i(16, 16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	# Static Walls
	var walls = [
		Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(4, 1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)
	]
	for wall in walls:
		astar.set_point_solid(wall)

# --- Core Logic ---

func reconstruct_grid_visuals() -> void:
	tile_map.clear()
	
	# Snapshot keys to avoid modification errors during the loop
	var initial_origins = occupied_cell.keys()
	var processed_ids = {} 
	
	for cell_pos in initial_origins:
		var trash: TrashShape = occupied_cell[cell_pos]
		var id = trash.get_instance_id()
		
		# Skip if we already initialized this specific item instance
		if processed_ids.has(id):
			continue
		processed_ids[id] = true
		
		# SYNC POSITION
		trash.set_last_origin(cell_pos)
		var origin = trash.get_last_origin()
		
		# SYNC ROTATION
		var target_degree = trash.get_rotation()
		var rot_steps = int(target_degree / 90) % 4
		
		# Reset to 0 so we can spin it fresh
		trash.set_rotation(0) 
		
		# Apply rotation X times to calculate new offsets
		for _step in range(rot_steps):
			trash.rotate()
		
		trash.last_rotated_degree = trash.get_rotation()
		# Draw & Fill Dictionary
		var i = 0
		
		for offset in trash.offset:
			var target = origin + offset
			
			# Add collision data for the calculated offsets
			occupied_cell[target] = trash
			
			# Draw visual
			tile_map.set_cell(target, trash.atlas_id, trash.atlas_coords[i], TILE_ROTATIONS[rot_steps])
			astar.set_point_solid(target)
			i += 1
		
	redraw_path()

func place_item(origin: Vector2i, trash: TrashShape) -> void:
	var rot_index = int(trash.get_rotation() / 90) % 4
	var i = 0
	
	for offset in trash.offset:
		var target = origin + offset
		
		occupied_cell[target] = trash
		astar.set_point_solid(target)
		tile_map.set_cell(target, trash.atlas_id, trash.atlas_coords[i], TILE_ROTATIONS[rot_index])
		i += 1
	
	trash.set_last_origin(origin)
	grid_updated.emit()
	redraw_path()

func get_item(clicked_pos: Vector2i) -> TrashShape:
	if not occupied_cell.has(clicked_pos):
		return null

	var item_to_pickup: TrashShape = occupied_cell[clicked_pos]
	
	# Collect all cells used by this item
	var cells_to_clear: Array[Vector2i] = []
	for cell in occupied_cell:
		if occupied_cell[cell] == item_to_pickup:
			cells_to_clear.append(cell)

	# Clear them
	for cell in cells_to_clear:
		occupied_cell.erase(cell)
		tile_map.erase_cell(cell)
		astar.set_point_solid(cell, false)

	#grid_updated.emit()
	redraw_path()
	return item_to_pickup

func check_item(hovered_pos):
	if not occupied_cell.has(hovered_pos):
		return null
	
	return true

# --- Helpers ---

func is_area_valid(origin: Vector2i, offsets: Array[Vector2i]) -> bool:
	for offset in offsets:
		var target = origin + offset
		
		if not astar.region.has_point(target): return false
		if astar.is_point_solid(target): return false
		if occupied_cell.has(target): return false
		if target == start_pos or target == end_pos: return false
	return true

func check_path() -> bool:
	return not astar.get_id_path(start_pos, end_pos).is_empty()

func redraw_path() -> bool:
	path_line.clear_points()
	var path = astar.get_id_path(start_pos, end_pos)
	
	if path.is_empty():
		return false
	
	for point in path:
		path_line.add_point(tile_map.map_to_local(point))
	return true
