extends Node

var is_dialogue_active: bool = false
var is_cutscene_active: bool = false

func is_interaction_locked():
	return is_dialogue_active or is_cutscene_active
