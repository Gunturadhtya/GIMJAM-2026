class_name PNGToAtlas

var full_spritesheet: Texture2D

func setup(spritesheet_path):
	full_spritesheet = spritesheet_path

func get_item_icon(grid_x: int, grid_y: int, w: int, h: int) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = full_spritesheet
	
	var rect = Rect2(grid_x * 16, grid_y * 16, w * 16, h * 16)
	
	atlas.region = rect
	return atlas
