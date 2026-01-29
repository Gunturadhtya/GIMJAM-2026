extends Node2D

var intro_text: Array = [
	"Rafi worked endless shifts|0.3| to save his sister.",
	"But she passed away|0.6| while he was at work.",
	"Now,|0.5| he never leaves his apartment.",
	"He spends the savings on delivery,|0.4| hiding from the world.",
	"The room is messy.|0.8| The air is still.",
	"He thinks he is the only one here.",
	"He is|1.0| wrong."
]

func _ready() -> void:
	
	$AnimationPlayer.play("fade_in")
	
	await $AnimationPlayer.animation_finished
	
	$CanvasLayer/IntroUI/Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	$CanvasLayer/IntroUI/Dialogue.start_sequence(intro_text)

func _on_dialogue_finished():
	$AnimationPlayer.play("fade_out")
	
	await $AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_file("res://Scene/Stages/Day1Stage.tscn")
