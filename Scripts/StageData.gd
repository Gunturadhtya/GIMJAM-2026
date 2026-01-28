class_name StageData extends Resource

@export var title: String = "Title"
@export var day: int = 1
@export_multiline var description: String = ""
@export var trash_goal: int = 0
@export var grid_content: Dictionary[Vector2i, TrashShape]
