extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	level.ghost_cursor.visible = false
	level.held_visual.visible = false
	print("State: Idle")

func handle_input(_event: InputEvent):
	if _event.is_action_pressed("ui_accept"):
		level.add_random_item_to_inventory()
		
		get_viewport().set_input_as_handled()
