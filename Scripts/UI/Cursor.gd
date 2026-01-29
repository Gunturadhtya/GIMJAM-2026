extends AnimatedSprite2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	play("idle")

func _input(event):
	if event is InputEventMouseMotion:
		global_position = event.position

func play_grab():
	play("grab")

func play_hold():
	play("hold")

func play_idle():
	play("idle")
