extends Node2D

const CELL_SIZE = 16

func update_visuals(offsets: Array[Vector2i]):
	for child in get_children():
		child.queue_free()
	
	for offset in offsets:
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://icon.svg")
		sprite.scale = Vector2(0.125, 0.125)
		sprite.position = Vector2(offset) * CELL_SIZE
		sprite.modulate.a = 0.5
		add_child(sprite)


func set_color_status(is_valid: bool):
	self.modulate = Color.GREEN if is_valid else Color.RED
