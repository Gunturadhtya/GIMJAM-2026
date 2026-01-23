extends TextureRect

@export var item_data: TrashShape 

func _ready():
	if item_data:
		_update_visuals()

func setup(data: TrashShape):
	item_data = data 
	_update_visuals()

func _update_visuals():
	if item_data:
		texture = item_data.texture
		modulate = item_data.color

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		if item_data == null:
			return

		var level = get_tree().get_first_node_in_group("LevelManager")
		
		if level:
			level.start_dragging_item(item_data.get_copy())
			
			queue_free()
