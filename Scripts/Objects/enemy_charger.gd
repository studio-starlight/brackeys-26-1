class_name EnemyCharger
extends BaseEnemy

@export var charge_speed : float = 20
@export var acceleration : float = 5.0
var chase_duration : float = 3.4
var attack_duration : float = 2.9
var collision_offset : float = 4.0
@onready var animator: AnimationPlayer = $Animator
@onready var deal_damage_box: DealDamageBox = $DealDamageBox
@onready var chase_timer: Timer = $ChaseTimer
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	super()
	chase_timer.timeout.connect(_on_chase_finished)
	attack_timer.timeout.connect(_on_attack_finished)

func _chase() -> void:
	if chase_timer.is_stopped():
		chase_timer.start()
	
	var circle_position : Vector2 = get_circle_position()
	move_direction = (circle_position - global_position).normalized()
	velocity = move_direction * stats.speed
	move_and_slide()

func _attack(delta : float) -> void:
	move_direction = (player.global_position - global_position).normalized()
	_accelerate(delta)
	move_and_slide()

func _handle_animation() -> void:
	if is_dead:
		animator.play("hit")
		return
	if is_facing_right:
		deal_damage_box.position.x = collision_offset
	else:
		deal_damage_box.position.x = -collision_offset
	match current_state:
		EnemyState.CHASE:
			animator.play("run")
		EnemyState.ATTACK:
			animator.play("attack")
		EnemyState.HIT:
			animator.play("hit")

func _accelerate(delta : float) -> void:
	velocity = velocity.lerp(move_direction * charge_speed, acceleration * delta)

func _on_chase_finished() -> void:
	if current_state == EnemyState.CHASE:
		attack_timer.start(attack_duration)
		change_state(EnemyState.ATTACK)

func _on_attack_finished() -> void:
	if current_state == EnemyState.ATTACK:
		chase_timer.start(chase_duration)
		change_state(EnemyState.CHASE)
