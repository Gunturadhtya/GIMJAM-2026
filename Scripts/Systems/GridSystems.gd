class_name GridSystem extends Node

signal grid_updated

@export var tile_map: TileMapLayer
@export var path_line: Line2D
@export var grid_size := Vector2i(16, 16)

var astar := AStarGrid2D.new()
var occupied_cell = {} # {Vector2i : TrashShape}
var start_pos := Vector2i(1,1)
var end_pos := Vector2i(14,14)

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
	for offset in trash.offset:
		var target = origin + offset
		occupied_cell[target] = trash
		tile_map.set_cell(target, 1, Vector2i(2,1)) # ubah kordinat atlas menjadi texture dari trash
		astar.set_point_solid(target)
	
	grid_updated.emit()
	redraw_path()
	

func redraw_path():
	path_line.clear_points()
	var path = astar.get_id_path(start_pos, end_pos)
	
	if path.is_empty():
		return false
	
	for point in path:
		path_line.add_point(tile_map.map_to_local(point))
	
	return true
