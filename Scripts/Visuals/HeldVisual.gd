extends Node2D

@onready var visual_root = $VisualRoot 
@onready var sprite = $VisualRoot/Sprite2D

func setup(data: TrashShape):
	if data.texture:
		sprite.texture = data.texture
	
	visual_root.position = Vector2.ZERO 
