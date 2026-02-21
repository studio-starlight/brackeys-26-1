class_name CutsceneManager
extends Node2D

@onready var cutscene_animator: AnimationPlayer = $CutsceneAnimator
@onready var cutscene_delay_timer: Timer = $CutsceneDelayTimer
@onready var dialogue: TextureRect = $Dialogue
@onready var dialogue_sound_player: AudioStreamPlayer = $DialogueSoundPlayer
@onready var dialogue_text: RichTextLabel = $Dialogue/Margins/DialogueText
@onready var speaker_sprite: Sprite2D = $Dialogue/Speaker/SpeakerSprite

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
		GameManager.StoryEvent.START:
			current_cutscene = cutscenes.get(0)
		GameManager.StoryEvent.WAVE1:
			current_cutscene = cutscenes.get(1)
		GameManager.StoryEvent.WAVE2:
			current_cutscene = cutscenes.get(2)
		GameManager.StoryEvent.WAVE3:
			current_cutscene = cutscenes.get(3)
		GameManager.StoryEvent.WAVE4:
			current_cutscene = cutscenes.get(4)
		GameManager.StoryEvent.WAVE5:
			current_cutscene = cutscenes.get(5)
		GameManager.StoryEvent.WAVE6:
			current_cutscene = cutscenes.get(6)
		GameManager.StoryEvent.WAVE7:
			current_cutscene = cutscenes.get(7)
		GameManager.StoryEvent.WAVE8:
			current_cutscene = cutscenes.get(8)
		GameManager.StoryEvent.WAVE9:
			current_cutscene = cutscenes.get(9)
		GameManager.StoryEvent.WAVE10:
			current_cutscene = cutscenes.get(10)
		_:
			current_cutscene = cutscenes.get(cutscenes.size() - 1)
	if current_cutscene == null:
		printerr("Cutscene not assigned")
		current_cutscene = cutscenes.get(0)
	current_item = 0
	is_active = true
	next_item = true
	current_item = 0
	player.disabled = true
	dialogue_text.text = ""
	visible = true
	advance_cutscene()

func _process(delta: float) -> void:
	pass
	#if !is_active:
		#return
	#
	#if next_item:
		#next_item = false
		#advance_cutscene()

func advance_cutscene() -> void:
	if current_item == current_cutscene.cutscene_data.size():
		finish_cutscene()
		return
	
	var i = current_cutscene.cutscene_data[current_item]
	current_item += 1
	if i is CutsceneAnimationData:
		if i.hide_dialogue_box:
			dialogue.visible = false
		else:
			dialogue.visible = true
		_start_animation(i)
	elif i is CutsceneTextData:
		dialogue.visible = true
		_start_dialogue(i)
	else:
		printerr("ERROR, INVALID RESOURCE!")
		current_item += 1
		next_item = true

func finish_cutscene() -> void:
	if GameManager.get_story_event() == GameManager.StoryEvent.WAVE10:
		return
	EventBus.cutscene_end.emit()
	is_active = false
	visible = false
	next_item = false

func _start_animation(i : CutsceneAnimationData) -> void:
	cutscene_animator.play(i.animation_name)
	if i.wait_for_animation_finished:
		await cutscene_animator.animation_finished
	advance_cutscene()

func _start_dialogue(i : CutsceneTextData) -> void:
	if !i.speaker_img:
		speaker_sprite.visible = false
	else:
		speaker_sprite.visible = true
		speaker_sprite.texture = i.speaker_img
		speaker_sprite.hframes = i.speaker_img_Hframes
		speaker_sprite.frame = 0
	
	dialogue_text.visible_characters = 0
	dialogue_text.text = i.text
	var text_without_square_brackets: String = _text_without_square_brackets(i.text)
	var total_characters: int = text_without_square_brackets.length()
	var character_timer: float = 0.0
	
	while dialogue_text.visible_characters < total_characters:
		if Input.is_action_just_pressed("cancel") && i.skippable:
			dialogue_text.visible_characters = total_characters
			break
		
		character_timer += get_process_delta_time()
		if character_timer >= (1.0 / i.text_speed) or text_without_square_brackets[dialogue_text.visible_characters] == " ":
			var character: String = text_without_square_brackets[dialogue_text.visible_characters]
			dialogue_text.visible_characters += 1
			if character != " ":
				dialogue_sound_player.pitch_scale = randf_range(i.text_volume_pitch_min,i.text_volume_pitch_max)
				dialogue_sound_player.play()
				if i.speaker_img_Hframes != 1:
					if speaker_sprite.frame < i.speaker_img_Hframes - 1:
						speaker_sprite.frame += 1
					else:
						speaker_sprite.frame = 0
			character_timer = 0.0
		await get_tree().process_frame
	
	var waiting_for_input : bool = true
	while waiting_for_input:
		await get_tree().process_frame
		if Input.is_action_just_pressed("attack"):
			waiting_for_input = false
	advance_cutscene()
	
	#while true:
		#if !is_inside_tree():
			#return
		#await get_tree().process_frame
		#if dialogue_text.visible_characters == total_characters:
			#if Input.is_action_just_pressed("attack"):
				#current_item += 1
				#next_item = true

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
