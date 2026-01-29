extends ColorRect

@export var my_palette: Array[Color] = [
	Color8(23, 17, 26),
	Color8(70, 53, 84),
	Color8(85, 81, 111),
	Color8(171, 153, 164),
	Color8(245, 239, 232),
	Color8(144, 181, 198),
	Color8(110, 126, 141),
	Color8(56, 65, 80),
	Color8(107, 102, 87),
	Color8(154, 148, 92),
	Color8(218, 194, 130),
	Color8(201, 141, 63),
	Color8(131, 68, 62),
	Color8(97, 49, 64),
	Color8(57, 32, 46),
	Color8(89, 58, 49)
]

func _ready():
	var shader_palette = []
	for color in my_palette:
		shader_palette.append(Vector3(color.r, color.g, color.b))
	
	material.set_shader_parameter("palette", shader_palette)
	material.set_shader_parameter("palette_size", my_palette.size())
