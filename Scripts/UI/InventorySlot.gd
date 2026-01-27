extends PanelContainer 

var icon: TextureRect
@export var item_data: TrashShape 

func setup(data: TrashShape):
	item_data = data
	icon = TextureRect.new()
	add_child(icon)
	icon.texture = item_data.texture

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if item_data == null: return

		var level = get_tree().get_first_node_in_group("LevelManager")
		if level:
			level.start_dragging_item(self) 
			
			icon.modulate.a = 0.0

func show_item():
	if icon:
		icon.modulate.a = 1.0
	else:
		setup(item_data)
		show_item()

func consume_item():
	queue_free()
