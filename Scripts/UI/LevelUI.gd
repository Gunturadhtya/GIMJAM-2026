extends Control

@onready var desc_label = $Description

func setup(data: StageData):
	var text = "[color=#e4c892]%s[/color]\n" % data.title
	text += "Day %d\n\n" % data.day
	text += "[color=#9bd2d9]%s[/color]" % data.description
	desc_label.text = text
