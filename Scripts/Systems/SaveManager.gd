extends Node

const SAVE_PATH = "user://savegame.save"

# Default to Level 1
var current_level_id: int = 1

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(current_level_id)

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		current_level_id = file.get_var()
	else:
		current_level_id = 1 # Fallback if file missing

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset_data():
	current_level_id = 1
	save_game()
