class_name GameData extends Resource

const TRASH_FOLDER = "res://Data/"

static func get_random_shape() -> TrashShape:
	var dir = DirAccess.open(TRASH_FOLDER)
	if dir:
		var files = dir.get_files()
		var valid_files = []
		for f in files:
			if f.ends_with(".tres") or f.ends_with(".remap"):
				valid_files.append(f.replace(".remap", "")) 
		
		if valid_files.size() > 0:
			var random_file = valid_files.pick_random()
			return load(TRASH_FOLDER + random_file).duplicate() 
	
	return null
