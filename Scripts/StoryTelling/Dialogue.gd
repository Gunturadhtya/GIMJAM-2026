extends RichTextLabel

signal dialogue_finished
signal player_advanced

@export var voice_sound: AudioStream
@export var base_pitch: float = 1.0
@export var default_text_speed: float = 0.1

var _is_typing: bool = false
var _current_line_index: int = 0
var _dialogue_data: Array = []

func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("click"):
		player_advanced.emit()

func start_sequence(lines: Array):
	_dialogue_data = lines
	_current_line_index = 0
	_display_next_line()

func _display_next_line():
	if _current_line_index >= _dialogue_data.size():
		dialogue_finished.emit()
		return
		
	var raw_text = _dialogue_data[_current_line_index]
	
	await _type_text(raw_text)
	
	await player_advanced 
	
	_current_line_index += 1
	_display_next_line()

func _type_text(full_string: String):
	_is_typing = true
	
	var pauses = {} 
	var clean_text = ""
	var regex = RegEx.new()
	regex.compile("\\|(\\d+\\.?\\d*)\\|")
	var last_offset = 0
	for result in regex.search_all(full_string):
		clean_text += full_string.substr(last_offset, result.get_start() - last_offset)
		pauses[clean_text.length()] = float(result.get_string(1))
		last_offset = result.get_end()
	clean_text += full_string.substr(last_offset)

	self.text = clean_text
	self.visible_characters = 0

	while visible_characters < clean_text.length():
		if pauses.has(visible_characters):
			await get_tree().create_timer(pauses[visible_characters]).timeout
			
		visible_characters += 1
		
		var current_char = clean_text[visible_characters - 1]
		if current_char != " ":
			var shift = randf_range(-0.1, 0.1)
			AudioManager.play_voice_blip(voice_sound, base_pitch + shift)
			
		await get_tree().create_timer(default_text_speed).timeout
	
	await get_tree().process_frame 
	_is_typing = false
