extends PanelContainer

var icon: TextureRect
var shadow: TextureRect
@export var item_data: TrashShape 

# --- Animation Settings ---
const HOVER_SCALE = Vector2(1.15, 1.15)
const CLICK_SCALE = Vector2(0.9, 0.9)
const NORMAL_SCALE = Vector2(1.0, 1.0)
const TILT_SENSITIVITY = 0.08 

# Shadow Settings
const SHADOW_COLOR = Color(0, 0, 0, 0.4) 
const MAX_SHADOW_OFFSET = Vector2(12, 12)

var current_tween: Tween

func setup(data: TrashShape):
	item_data = data
	
	# Setup the Shadow
	shadow = TextureRect.new()
	shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shadow.texture = item_data.texture
	shadow.modulate = SHADOW_COLOR
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	add_child(shadow)
	
	# Setup the Icon
	icon = TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = item_data.texture
	add_child(icon)
	
	# Center Pivots
	await get_tree().process_frame
	_update_pivot()
	
	set_process(false)
	
	# Connect signals
	icon.resized.connect(_update_pivot)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _update_pivot():
	# Update both pivots
	if icon: icon.pivot_offset = icon.size / 2.0
	if shadow: shadow.pivot_offset = shadow.size / 2.0

# --- The Juice ---

func _on_mouse_entered():
	if item_data == null: return
	_animate_scale(HOVER_SCALE)
	set_process(true)

func _on_mouse_exited():
	if item_data == null: return
	_animate_scale(NORMAL_SCALE)
	
	# Reset rotation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(icon, "rotation_degrees", 0.0, 0.1)
	
	set_process(false)
	
	if shadow: shadow.position = Vector2.ZERO

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_animate_scale(CLICK_SCALE)
			if item_data:
				var level = get_tree().get_first_node_in_group("LevelManager")
				if level:
					level.start_dragging_item(self)
					# Hide both
					icon.modulate.a = 0.0
					shadow.modulate.a = 0.0
		elif not event.pressed:
			_animate_scale(HOVER_SCALE)

func _animate_scale(target_scale: Vector2):
	if current_tween: current_tween.kill()
	
	current_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	current_tween.tween_property(icon, "scale", target_scale, 0.15)

func _process(_delta):
	if not icon or not shadow: return
	
	# Calculate Tilt
	var mouse_pos = icon.get_local_mouse_position()
	var center = icon.size / 2.0
	var dist = mouse_pos - center
	var tilt_x = dist.x * TILT_SENSITIVITY
	
	# Apply Tilt to Icon
	icon.rotation_degrees = lerp(icon.rotation_degrees, tilt_x, 0.2)
	
	# Calculate Lift
	# Map scale 1.0 -> 0 offset, Scale 1.5 -> Max Offset
	var lift_factor = (icon.scale.x - 1.0) * 2.0 
	lift_factor = clamp(lift_factor, 0.0, 1.0)
	
	var target_shadow_offset = MAX_SHADOW_OFFSET * lift_factor
	
	# Apply Inverse Tilt to Shadow 
	var parallax_offset = Vector2(tilt_x * -0.5, abs(tilt_x) * 0.2)
	
	# Force Shadow Position (Overrides PanelContainer layout)
	shadow.position = target_shadow_offset + parallax_offset

# --- Standard Logic ---
func show_item():
	if icon:
		icon.modulate.a = 1.0
		shadow.modulate.a = 1.0
		_animate_scale(NORMAL_SCALE)
		icon.rotation = 0
		shadow.position = Vector2.ZERO
	else:
		setup(item_data)
		show_item()

func consume_item():
	queue_free()
