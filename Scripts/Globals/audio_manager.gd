extends Node

var players := self.get_children()

func play_sound(sound) -> void:
	for player : AudioStreamPlayer in players:
		if !player.playing:
			player.stream = sound
			player.play()
