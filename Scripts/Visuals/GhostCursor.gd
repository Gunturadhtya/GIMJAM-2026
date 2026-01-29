extends Node2D

const CELL_SIZE = 16

func update_visuals(shape: TrashShape):
	for child in get_children():
		child.queue_free()
	
	var i = 0
	for offset in shape.offset:
		var sprite = Sprite2D.new()
		sprite.texture = load("res://Assets/ui/tile_highlight.png")
		sprite.hframes = 2
		sprite.vframes = 1
		sprite.frame = 1
		sprite.position = Vector2(offset) * CELL_SIZE
		sprite.modulate.a = 1.0 
		add_child(sprite)

func set_color_status(is_valid: bool):
	var target_color = Color.WHITE if is_valid else Color.RED
	for child in get_children():
		child.modulate = target_color
