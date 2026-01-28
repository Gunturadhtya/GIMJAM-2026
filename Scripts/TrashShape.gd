class_name TrashShape extends Resource

@export var atlas_id: int = 0 # atlas_id
@export var texture: Texture2D = null; # icon bar
@export var atlas_coords: Array[Vector2i] = [Vector2i(0, 0)] # digunakan pada tile
@export var offset: Array[Vector2i] = [Vector2i(0,0)]
@export var _rotated_degree: int = 0
@export var _last_origin: Vector2i = Vector2.ZERO
@export var last_rotated_degree: int = 0

func rotate():
	var new_offsets: Array[Vector2i] = []
	for points in offset:
		new_offsets.append(Vector2i(-points.y, points.x))
	offset = new_offsets
	set_rotation((_rotated_degree + 90) % 360)

func get_copy() -> TrashShape:
	var copy = self.duplicate(true)
	copy.offset = offset.duplicate()
	copy.set_degree(_rotated_degree)
	return copy

func get_last_origin():
	return _last_origin

func set_last_origin(new_origin: Vector2i):
	_last_origin = new_origin

func get_rotation():
	return _rotated_degree

func set_rotation(new_degree: int):
	_rotated_degree = new_degree
