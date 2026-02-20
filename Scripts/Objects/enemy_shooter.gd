class_name EnemyShooter
extends BaseEnemy

var chase_duration : float = 2.3
var attack_duration : float = 1.2
@onready var pivot: Marker2D = $Pivot
@onready var chase_timer: Timer = $ChaseTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var animator: AnimationPlayer = $Animator

func _ready() -> void:
	super()
	chase_timer.timeout.connect(_on_chase_finished)
	attack_timer.timeout.connect(_on_attack_finished)

func spawn_bullet() -> void:
	var new_bullet = Bullet.new_bullet(pivot.global_position, player.global_position, stats.attack)
	AudioManager.play_sound(AudioManager.SOUND_SHOOT)
	get_parent().add_child(new_bullet)

func _chase() -> void:
	if chase_timer.is_stopped():
		chase_timer.start()
	
	var circle_position : Vector2 = get_circle_position()
	move_direction = (circle_position - global_position).normalized()
	velocity = move_direction * stats.speed
	move_and_slide()

func _attack(delta : float) -> void:
	var lerp_weight : float = 5.6
	velocity = lerp(velocity, Vector2.ZERO, lerp_weight * delta)
	move_and_slide()

func _handle_animation() -> void:
	if is_dead:
		animator.play("hit")
		return
	match current_state:
		EnemyState.CHASE:
			animator.play("run")
		EnemyState.ATTACK:
			animator.play("attack")
		EnemyState.HIT:
			animator.play("hit")

func _on_chase_finished() -> void:
	if current_state == EnemyState.CHASE:
		attack_timer.start(attack_duration)
		change_state(EnemyState.ATTACK)

func _on_attack_finished() -> void:
	if current_state == EnemyState.ATTACK:
		chase_timer.start(chase_duration)
		change_state(EnemyState.CHASE)
