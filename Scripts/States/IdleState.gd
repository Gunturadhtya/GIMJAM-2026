extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	var path_exist = level.grid_system.redraw_path()
	
	print("State: Idle")

func handle_input(_event: InputEvent) -> void:
	# ini untuk debugging saja, 
	# tekan tombol yang linked dengan ui_accept akan memspawn sampah baru yang siap di letakkan
	if _event.is_action_pressed("ui_accept"):
		var test_trash = preload("res://Data/L3Shape.tres").duplicate()
		finished.emit(DRAGGING, {"trash" : test_trash})
