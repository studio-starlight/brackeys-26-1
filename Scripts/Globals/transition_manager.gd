extends CanvasLayer

@onready var animator: AnimationPlayer = $Animator

func play_transition(transition_type : String, transition_location : String = "none") -> void:
	
	visible = true
	animator.play(transition_type)
	if transition_location != "none":
		await animator.animation_finished
		get_tree().change_scene_to_file(transition_location)
