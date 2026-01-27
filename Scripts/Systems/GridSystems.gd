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
var occupied_cell = {} # {Vector2i : TrashShape}


func _ready() -> void:
	_setup_astar()
	redraw_path()

func _setup_astar():
	astar.region = Rect2i(0, 0, grid_size.x, grid_size.y)
	astar.cell_size = Vector2i(16, 16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func is_area_valid(origin: Vector2i, offsets: Array[Vector2i]):
	for offset in offsets:
		var target = origin + offset
		
		if not astar.region.has_point(target): return false
		if occupied_cell.has(target): return false
		if target == start_pos or target == end_pos: return false
	return true

func place_item(origin: Vector2i, trash: TrashShape):
	var i = 0
	for offset in trash.offset:
		var target = origin + offset
		occupied_cell[target] = trash
		tile_map.set_cell(target, trash.atlas_id, trash.atlas_coords[i], TILE_ROTATIONS[(trash.rotated_degree/90)]) # ubah kordinat atlas menjadi texture dari trash
		astar.set_point_solid(target)
		i += 1
	
	grid_updated.emit()
	redraw_path()

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
