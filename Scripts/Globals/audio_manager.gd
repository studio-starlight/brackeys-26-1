extends Node

const SOUND_ATTACK_HIT = preload("uid://c5sbjrmgb4sex")
const SOUND_FOOTSTEP = preload("uid://daeyhaugmx43k")
const SOUND_PLAYER_HURT = preload("uid://cfaqa0fyud2py")
const SOUND_SWING = preload("uid://266gavu72omt")
const SOUND_SHOOT = preload("uid://qasei75xhywk")
const SOUND_BUTTON_HOVER = preload("uid://p5dd1cmetqf4")
const SOUND_ENEMY_DEFEATED = preload("uid://ehdpp6r3prkq")
const SOUND_WAVE_END = preload("uid://cawjbw1f12pox")
const SOUND_BUTTON_CLICK = preload("uid://b1p2i2xvyhe3k")
const SOUND_BULLET_DESTROY = preload("uid://b63rnjx7oru2n")
const SOUND_SPAWN_ENEMY = preload("uid://ccq1xwuaj0ft")

var players : Array[Node]

func _ready() -> void:
	players = get_children()

func play_sound(sound: AudioStreamWAV, pitch_variation : float = 0) -> void:
	for player : AudioStreamPlayer in players:
		if !player.playing:
			player.stream = sound
			player.pitch_scale = randf_range(1 - pitch_variation, 1 + pitch_variation)
			player.play()
			break
