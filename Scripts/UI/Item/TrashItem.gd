extends Node2D

@onready var sprite = $Visuals/Sprite
@onready var collision_poly = $ClickArea/CollisionPolygon2D 

func setup(trash: TrashShape) -> void:
	sprite.texture = trash.texture
	_update_collision_shape_from_sprite()

func _update_collision_shape_from_sprite():
	if sprite.texture == null:
		return

	# Create a Bitmap from the texture
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(sprite.texture.get_image())
	
	# Convert Bitmap to Polygon
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, sprite.texture.get_size()), 2.0) 
	
	if polys.size() > 0:
		collision_poly.polygon = polys[0]
		
		# Optional: Center the polygon if your sprite is centered
		var offset = -sprite.texture.get_size() / 2.0
		collision_poly.position = offset
