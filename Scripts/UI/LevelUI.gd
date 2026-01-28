extends Control

@onready var desc_label = $Description

func setup(data: StageData):
	var text = "[color=#e4c892]%s[/color]\n\n" % data.title
	text += "[color=#f5efe8]%s[/color]" % data.description
	text += "[color=#9bd2d9]%s[/color]" % data.goal
	desc_label.text = text
