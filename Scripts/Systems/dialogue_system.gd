extends Node2D

@onready var dialogue_text: RichTextLabel = $HBoxContainer/VBoxContainer/RichTextLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var dialogue: Array[Dialogue]
var current_item: int = 0
var next_item: bool = true

var player: Player

func _ready() -> void:
	visible = false
	
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if current_item == dialogue.size():
		if !player:
			player = get_tree().get_first_node_in_group("player")
			return
		player.disabled = false
		queue_free()
		return
	
	if next_item:
		next_item = false
		var i = dialogue[current_item]
		
		if i is DialogueFunction:
			if i.hide_dialogue_box:
				visible = false
			else:
				visible = true
			_function_resource(i)
		elif i is DialogueText:
			visible = true
			_text_resource(i)
		else:
			printerr("ERROR, INVALID TEXT RESOURCE!")
			current_item += 1
			next_item = true

func _function_resource(i : DialogueFunction) -> void:
	var target_node = get_node(i.target_path)
	if target_node.has_method(i.function_name):
		if i.function_arguments.size() == 0:
			target_node.call(i.function_name)
		else:
			target_node.callv(i.function_name, i.function_arguments)
	
	if i.wait_for_signal_to_continue:
		var signal_name = i.wait_for_signal_to_continue
		if target_node.has_signal(signal_name):
			var signal_state = {"done": false}
			var callable = func(_args): signal_state.done = true
			target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
			while not signal_state.done:
				await get_tree().process_frame
	
	current_item += 1
	next_item = true

func _text_resource(i: DialogueText) -> void:
	audio_player.stream = i.text_sound
	audio_player.volume_db = i.text_volume_db
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera and i.camera_position !=  Vector2(999.999, 999.999):
		var camera_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		camera_tween.tween_property(camera, "global_position", i.camera_position, i.camera_transition_time)
	
	dialogue_text.visible_characters = 0
	dialogue_text.text = i.text
	var text_without_square_brackets: String = _text_without_square_brackets(i.text)
	var total_characters: int = text_without_square_brackets.length()
	var character_timer: float = 0.0
	while dialogue_text.visible_characters < total_characters:
		if Input.is_action_just_pressed("cancel"):
			dialogue_text.visible_characters = total_characters
			break
		
		character_timer += get_process_delta_time()
		if character_timer >= (1.0 / i.text_speed) or text_without_square_brackets[dialogue_text.visible_characters] == " ":
			var character: String = text_without_square_brackets[dialogue_text.visible_characters]
			dialogue_text.visible_characters += 1
			if character != " ":
				audio_player.pitch_scale = randf_range(i.text_volume_pitch_min,i.text_volume_pitch_max)
				audio_player.play()
				
			character_timer = 0.0
		await get_tree().process_frame
	
	while true:
		await  get_tree().process_frame
		if dialogue_text.visible_characters == total_characters:
			if Input.is_action_just_pressed("attack"):
				current_item += 1
				next_item = true

func _text_without_square_brackets(text: String) -> String:
	var result : String = ""
	var inside_bracket: bool = false
	
	for i in text:
		if i == "[":
			inside_bracket = true
			continue
		
		if i == "]":
			inside_bracket = false
			continue
		
		if !inside_bracket:
			result += i
	
	return result
