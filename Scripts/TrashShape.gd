class_name TrashShape extends Resource

@export var atlas_id: int = 0 # atlas_id
@export var texture: Texture2D = null; # icon bar
@export var atlas_coords: Array[Vector2i] = [Vector2i(0, 0)] # digunakan pada tile
@export var offset: Array[Vector2i] = [Vector2i(0,0)]
var rotated_degree: int = 0

func rotate():
	var new_offsets: Array[Vector2i] = []
	for points in offset:
		new_offsets.append(Vector2i(-points.y, points.x))
	offset = new_offsets
	rotated_degree = (rotated_degree + 90) % 360

func get_copy() -> TrashShape:
	var copy = self.duplicate(true)
	copy.offset = offset.duplicate()
	copy.rotated_degree = rotated_degree
	return copy
