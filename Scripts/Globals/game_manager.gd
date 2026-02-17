extends Node

enum StoryEvent {
	START,
	WAVE1,
	WAVE2,
	WAVE3,
	WAVE4,
	WAVE5,
	WAVE6,
	WAVE7,
	WAVE8,
	WAVE9,
	WAVE10,
	ENDING
}
var current_story_event : StoryEvent

enum GameState {
	IN_WAVE,
	IN_CUTSCENE,
	PAUSED
}
var current_game_state : GameState

func advance_story_event() -> void:
	if current_story_event < StoryEvent.ENDING:
		current_story_event += 1 as StoryEvent

func get_story_event() -> StoryEvent:
	return current_story_event

func set_game_state(new_game_state : GameState) -> void:
	current_game_state = new_game_state

func get_game_state() -> GameState:
	return current_game_state
