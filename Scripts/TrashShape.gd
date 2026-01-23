class_name TrashShape extends Resource

@export var id: String = "base"
@export var texture: Texture2D = null; # digunakan nanti setelah texture siap
@export var color: Color = Color.WHITE
@export var atlas_coords: Array[Vector2i] = [Vector2i(0, 0)] # digunakan pada tile
@export var offset: Array[Vector2i] = [Vector2i(0,0)]

func rotate():
	var new_offsets: Array[Vector2i] = []
	for points in offset:
		new_offsets.append(Vector2i(-points.y, points.x))
	offset = new_offsets

func get_copy() -> TrashShape:
	var copy = self.duplicate()
	copy.offset = offset.duplicate()
	return copy
