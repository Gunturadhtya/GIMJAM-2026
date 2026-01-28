extends Node2D

@onready var visual_root = $VisualRoot 
@onready var sprite = $VisualRoot/Sprite2D
@onready var shadow = $Shadow 

func setup(data: TrashShape):
	if data.texture:
		sprite.texture = data.texture
		shadow.texture = data.texture
		shadow.modulate = Color(0, 0, 0, 0.4)
		shadow.position = Vector2(8, 8)

	visual_root.position = Vector2.ZERO
	visual_root.scale = Vector2.ONE
	visual_root.skew = 0.0
	

# Call this from your Dragging State every frame
func apply_swaying_effect(velocity_diff: Vector2, delta: float):
	# FAKE 3D ROTATION (Squash X axis based on horizontal movement)
	var tilt_strength = -0.005 
	var target_scale_x = 1.0 - abs(velocity_diff.x * tilt_strength)
	target_scale_x = clamp(target_scale_x, 0.6, 1.0) 
	
	visual_root.scale.x = lerp(visual_root.scale.x, target_scale_x, delta * 15.0)
	
	# SKEW (Shear the image slightly for speed feeling)
	var target_skew = velocity_diff.x * -0.002
	visual_root.skew = lerp(visual_root.skew, target_skew, delta * 15.0)
	
	# DYNAMIC SHADOW
	var shadow_offset = Vector2(8, 8) + (velocity_diff * -0.1)
	shadow.position = shadow.position.lerp(shadow_offset, delta * 10.0)
