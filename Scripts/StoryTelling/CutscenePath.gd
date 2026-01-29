extends Path2D

signal cutscene_finished

@onready var follow = $PathFollow2D
@onready var sprite = $PathFollow2D/Sprite2D

@export var move_speed_px: float = 20.0

func run_sequence(astar_points: Array[Vector2], stop_ratio: float, do_return: bool, level: int):
	Global.is_cutscene_active = true
	
	curve = Curve2D.new()
	for p in astar_points:
		curve.add_point(to_local(p))
	
	follow.progress_ratio = 0.0
	
	sprite.play("walk")
	await _tween_movement(stop_ratio)
	
	sprite.play("idle")
	await get_tree().create_timer(1.5).timeout
	
	match level:
		1:
			sprite.rotation_degrees = 0
			sprite.position = Vector2(-0.0, 7.0)
			sprite.play("scene_day1")
			await sprite.animation_finished
		3:
			sprite.rotation_degrees = 90
			sprite.position = Vector2(-7.0, 0.0)
			sprite.play("scene_day3")
			await sprite.animation_finished
		4:
			sprite.rotation_degrees = -90
			sprite.position = Vector2(7.0, 0.0)
			sprite.play("scene_day4")
			await sprite.animation_finished
	
	if do_return:
		sprite.flip_v = true
		sprite.play("walk")
		await _tween_movement(0.0)
		sprite.flip_h = false
	
	#sprite.play("idle")
	Global.is_cutscene_active = false
	cutscene_finished.emit()

func _tween_movement(target_ratio: float):
	var tween = create_tween()
	var start_px = follow.progress
	var end_px = target_ratio * curve.get_baked_length()
	var duration = abs(end_px - start_px) / move_speed_px
	
	tween.tween_property(follow, "progress_ratio", target_ratio, duration)
	await tween.finished
