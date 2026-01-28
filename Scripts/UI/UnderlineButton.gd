class_name UnderlineButton extends Button

@export var underline_color: Color = Color.WHITE
@export var line_thickness: float = 2.0

func _ready() -> void:
	#toggle_mode = true
	
	toggled.connect(func(_state): queue_redraw())

func _draw() -> void:
	if button_pressed:
		var font = get_theme_font("font")
		var font_size = get_theme_font_size("font_size")
		var style = get_theme_stylebox("pressed") 
		
		var string_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		
		var start_x = 0.0
		
		# DYNAMIC CALCULATION BASED ON ALIGNMENT
		match alignment:
			HORIZONTAL_ALIGNMENT_LEFT:
				start_x = style.content_margin_left
				
			HORIZONTAL_ALIGNMENT_CENTER:
				start_x = (size.x - string_size.x) / 2
				
			HORIZONTAL_ALIGNMENT_RIGHT:
				start_x = size.x - string_size.x - style.content_margin_right
		
		var end_x = start_x + string_size.x
		var line_y = (size.y + string_size.y) / 2  
		
		draw_line(Vector2(start_x, line_y), Vector2(end_x, line_y), underline_color, line_thickness)
