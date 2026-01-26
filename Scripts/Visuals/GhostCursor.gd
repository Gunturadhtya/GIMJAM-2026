extends Node2D

const CELL_SIZE = 16

func update_visuals(shape: TrashShape):
	for child in get_children():
		child.queue_free()
	
	var atlas = PNGToAtlas.new()
	atlas.setup(shape.texture)
	
	var i = 0
	for offset in shape.offset:
		var sprite = Sprite2D.new()
		sprite.texture = atlas.get_item_icon(shape.atlas_coords[i].x, shape.atlas_coords[i].y,1,1)
		sprite.rotation_degrees = shape.rotated_degree
		sprite.position = Vector2(offset) * CELL_SIZE
		sprite.modulate.a = 0.5
		i += 1
		add_child(sprite)


func set_color_status(is_valid: bool):
	self.modulate = Color.GREEN if is_valid else Color.RED
