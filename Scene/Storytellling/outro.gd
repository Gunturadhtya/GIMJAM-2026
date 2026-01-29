extends Node2D

var ending_text: Array = [
	"He finally|0.5| went outside.",
	"Please|0.4| keep taking pictures.",
	"The world|0.3| isn't so cruel|0.6| after all.",
	"Right,|0.8| brother?"
]

func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	
	await $AnimationPlayer.animation_finished
	
	$CanvasLayer/IntroUI/Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	$CanvasLayer/IntroUI/Dialogue.start_sequence(ending_text)

func _on_dialogue_finished():
	$AnimationPlayer.play("fade_out")
	
	await $AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_file("res://Scene/UI/Menu/StartMenu.tscn")
