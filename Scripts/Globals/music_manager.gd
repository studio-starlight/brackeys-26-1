extends Node

const MUSIC_BATTLE = preload("uid://cxxdre352qh8x")
const MUSIC_SPOOKY = preload("uid://dfd3i50oj101c")

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func play_music(music : AudioStreamOggVorbis, pitch : float = 1.0) -> void:
	if !player.playing:
		player.stream = music
		player.pitch_scale = pitch
		player.play()

func stop_music() -> void:
	player.stop()
