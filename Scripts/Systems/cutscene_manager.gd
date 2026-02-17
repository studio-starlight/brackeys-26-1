class_name CutsceneManager
extends Node2D

@onready var cutscene_animator: AnimationPlayer = $CutsceneAnimator
@onready var cutscene_delay_timer: Timer = $CutsceneDelayTimer
@onready var dialogue: TextureRect = $Dialogue
@onready var dialogue_sound_player: AudioStreamPlayer = $DialogueSoundPlayer
@onready var dialogue_text: RichTextLabel = $Dialogue/Margins/DialogueText

@export var cutscenes: Array[Cutscene]
var current_cutscene : Cutscene
var current_item: int = 0
var cutscene_delay_time : float = 0.5
var player : Player
var next_item : bool = true
var is_active : bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	dialogue.visible = false
	

func start_cutscene(current_story_scene : GameManager.StoryEvent) -> void:
	match current_story_scene:
		GameManager.StoryEvent.WAVE1:
			current_cutscene = cutscenes.get(0)
		GameManager.StoryEvent.WAVE2:
			current_cutscene = cutscenes.get(2)
	if current_cutscene == null:
		printerr("Cutscene not assigned")
		current_cutscene = cutscenes.get(0)
	current_item = 0
	is_active = true
	player.disabled = true
	dialogue_text.text = ""
	visible = true

func _process(delta: float) -> void:
	if !is_active || !is_inside_tree():
		return
	
	if current_item == current_cutscene.cutscene_data.size():
		if !player:
			player = get_tree().get_first_node_in_group("player")
			return
		player.disabled = false
		EventBus.emit_signal("cutscene_end")
		is_active = false
		visible = false
		return
	
	if next_item:
		
		next_item = false
		var i = current_cutscene.cutscene_data[current_item]
		
		if i is CutsceneAnimationData:
			dialogue.visible = false
			_start_animation(i)
		elif i is CutsceneTextData:
			dialogue.visible = true
			_start_dialogue(i)
		else:
			printerr("ERROR, INVALID RESOURCE!")
			current_item += 1
			next_item = true

func _start_animation(i : CutsceneAnimationData) -> void:
	cutscene_animator.play(i.animation_name)
	var signal_state = {"done": false}
	var callable = func(_args): signal_state.done = true
	cutscene_animator.connect("animation_finished", callable, CONNECT_ONE_SHOT)
	while not signal_state.done:
		await get_tree().process_frame
	current_item += 1
	next_item = true
func _start_dialogue(i : CutsceneTextData) -> void:
	if not is_inside_tree():
		return
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
				dialogue_sound_player.pitch_scale = randf_range(i.text_volume_pitch_min,i.text_volume_pitch_max)
				dialogue_sound_player.play()
				
			character_timer = 0.0
		await get_tree().process_frame
	
	while true:
		if !is_inside_tree():
			return
		await get_tree().process_frame
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
