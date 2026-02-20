extends Node

const MUSIC_BATTLE = preload("uid://cxxdre352qh8x")
@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func play_music(music : AudioStreamOggVorbis) -> void:
	if !player.playing:
		player.stream = music
		player.play()

func stop_music() -> void:
	player.stop()
