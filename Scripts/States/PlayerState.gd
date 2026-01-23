class_name PlayerState extends State

const IDLE = "Idle"
const DRAGGING = "Dragging"

var level: LevelManager

func _ready() -> void:
	await owner.ready
	level = owner as LevelManager
	
