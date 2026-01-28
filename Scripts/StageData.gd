class_name StageData extends Resource

@export var title: String = "Title"
@export_file("*.tscn") var next_scene: String
@export_multiline var description: String = ""
@export_multiline var goal: String = ""
@export var trash_goal: int = 0
@export var grid_content: Dictionary[Vector2i, TrashShape]
