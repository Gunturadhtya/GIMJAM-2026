class_name GridSystem extends Node

signal grid_updated

const TILE_ROTATIONS = [
	0,                                                                  # 0 degrees
	TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H, # 90 CW
	TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,     # 180 
	TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V  # 270 CW
]

@export var tile_map: TileMapLayer
@export var path_line: Line2D
@export var grid_size := Vector2i(8, 6)
@export var start_pos := Vector2i(1,1)
@export var end_pos := Vector2i(7,5)

var astar := AStarGrid2D.new()
@export var occupied_cell = {} # {Vector2i : TrashShape}

func _ready() -> void:
	_setup_astar()
	redraw_path()
	reconstruct_grid_visuals()

func _setup_astar():
	astar.region = Rect2i(0, 0, grid_size.x, grid_size.y)
	astar.cell_size = Vector2i(16, 16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar.update()
	
	# Hardcoding the wall
	astar.set_point_solid(Vector2i(1, 0))
	astar.set_point_solid(Vector2i(2, 0))
	astar.set_point_solid(Vector2i(3, 0))
	astar.set_point_solid(Vector2i(4, 0))
	astar.set_point_solid(Vector2i(4, 1))
	astar.set_point_solid(Vector2i(0, 0))
	astar.set_point_solid(Vector2i(0, 1))
	astar.set_point_solid(Vector2i(0, 2))

func is_area_valid(origin: Vector2i, offsets: Array[Vector2i]):
	for offset in offsets:
		var target = origin + offset
		
		if not astar.region.has_point(target): return false
		if astar.is_point_solid(target): return false
		if occupied_cell.has(target): return false
		if target == start_pos or target == end_pos: return false
	return true

func check_path():
	return !astar.get_id_path(start_pos, end_pos).is_empty()

func place_item(origin: Vector2i, trash: TrashShape):
	var i = 0
	for offset in trash.offset:
		var target = origin + offset
		occupied_cell[target] = trash
		tile_map.set_cell(target, trash.atlas_id, trash.atlas_coords[i], TILE_ROTATIONS[(trash.get_rotation()/90)]) # ubah kordinat atlas menjadi texture dari trash
		astar.set_point_solid(target)
		i += 1
	
	trash.set_last_origin(origin)
	grid_updated.emit()
	redraw_path()

## Uncomment this WHEN you want an inventory feature
#func place_item(origin: Vector2i, slot_node: Container):
	#var i = 0
	#var trash = slot_node.item_data
	#for offset in trash.offset:
		#var target = origin + offset
		#occupied_cell[target] = slot_node
		#tile_map.set_cell(target, trash.atlas_id, trash.atlas_coords[i], TILE_ROTATIONS[(trash.rotated_degree/90)]) # ubah kordinat atlas menjadi texture dari trash
		#astar.set_point_solid(target)
		#i += 1
	#
	#grid_updated.emit()
	#redraw_path()

func get_item(clicked_pos: Vector2i):
	# Check if there is actually an item here
	if not occupied_cell.has(clicked_pos):
		return null

	# Identify WHICH item we are picking up
	var item_to_pickup: TrashShape = occupied_cell[clicked_pos]

	# Find ALL grid cells occupied by this specific item instance
	var cells_to_clear: Array[Vector2i] = []
	
	for cell in occupied_cell:
		if occupied_cell[cell] == item_to_pickup:
			cells_to_clear.append(cell)

	# Clear them from the systems
	for cell in cells_to_clear:
		occupied_cell.erase(cell)          
		tile_map.erase_cell(cell)          
		astar.set_point_solid(cell, false) 

	grid_updated.emit()
	redraw_path()
	
	return item_to_pickup

func redraw_path():
	path_line.clear_points()
	var path = astar.get_id_path(start_pos, end_pos)
	
	if path.is_empty():
		return false
	
	for point in path:
		path_line.add_point(tile_map.map_to_local(point))
	
	return true

func reconstruct_grid_visuals() -> void:
	tile_map.clear()
	_setup_astar()
	
	# Stores { int (Instance ID) : bool }
	var processed_ids = {} 
	
	for cell_pos in occupied_cell:
		var trash: TrashShape = occupied_cell[cell_pos]
		
		# Get the unique ID of this specific object instance in memory
		var id = trash.get_instance_id()
		
		if processed_ids.has(id):
			continue
		
		# Mark this ID as processed so we don't draw it again for its other cells
		processed_ids[id] = true
		
		# Rendering Logic
		trash.set_last_origin(cell_pos)
		var origin = trash.get_last_origin() 
		var i = 0
		
		# Calculate rotation index for the TileMap
		var rot_index = int(trash.get_rotation() / 90) % 4
		
		trash.set_rotation(0)
		for rot in range(rot_index):
			trash.rotate()
		
		print(trash.get_rotation())
		
		for offset in trash.offset:
			var target = origin + offset
			
			# Safety Check: Ensure the target actually exists in our data
			occupied_cell[target] = trash 
			
			if not occupied_cell.has(target):
				push_warning("Grid Sync Error: Item expects cell ", target, " but it is empty.")
			
			# Update Visuals
			tile_map.set_cell(target, trash.atlas_id, trash.atlas_coords[i], TILE_ROTATIONS[rot_index])
			
			# Update Logic
			astar.set_point_solid(target)
			
			i += 1

	# Finalize Path
	redraw_path()
