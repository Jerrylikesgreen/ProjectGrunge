class_name MobBody extends CharacterBody2D

#------------------------------------------[Signals]------------------------------------------------------------------
signal _on_Mob_Body_State_Change(mob_body_state:MobBodyState)



#------------------------------------------[Variables]------------------------------------------------------------------------
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite2D = %Sprite2D

const SPEED       := 200.0
const JUMP_SPEED  := 400.0
const GRAVITY     := 900.0
const MOVE_EPS    := 0.5 

var _dir : float = 0.0        ## horizontal input  (-1 … +1)
var _jump: bool  = false      ## edge-trigger flag
var _is_moving := false
var _is_player_controled: bool = false
var was_state: MobBodyState = mob_body_state

enum MobBodyState { IDLE, ATTACKING, ACTION, MOVING }
@export var mob_body_state: MobBodyState = MobBodyState.IDLE

@export var projectile: PackedScene
@export var attack_wait_time: float = 0.5@export var projectile: PackedScene


#-------------------------[Process]-----------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	_apply_input(delta)
	_apply_gravity_jump(delta)
	_update_state_machine()
	move_and_slide()
	
#----------------------[Helpers]-------------------------------------------------------------------------------------------
func set_horizontal_input(dir: float) -> void:
	_dir = clamp(dir, -1.0, 1.0)

func request_jump() -> void:
	_jump = true


#--------------[Mob Body State Machine]--------------------------------------------------------------------



func _apply_input(delta: float) -> void:
	if abs(_dir) > 0.01:
		velocity.x = _dir * SPEED
		sprite.flip_h = _dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 4 * delta)

func _apply_gravity_jump(delta: float) -> void:
	if _jump and is_on_floor():
		velocity.y = -JUMP_SPEED
	_jump = false
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _update_state_machine() -> void:
	var new_state := mob_body_state

	if mob_body_state == MobBodyState.ATTACKING:
		return  # do not change state while attacking
	if not is_on_floor():
		new_state = MobBodyState.ACTION
	elif abs(velocity.x) > MOVE_EPS:
		new_state = MobBodyState.MOVING
	else:
		new_state = MobBodyState.IDLE

	_set_state(new_state)

func _set_state(new_state : MobBodyState) -> void:
	if new_state == mob_body_state:
		return                                 # nothing changed

	mob_body_state = new_state
	_apply_state_animation(mob_body_state)
	emit_signal("_on_Mob_Body_State_Change", mob_body_state)

func _apply_state_animation(s: MobBodyState) -> void:
	match s:
		MobBodyState.IDLE:   animation_player.play("idle")
		MobBodyState.MOVING: animation_player.play("walk")
		#MobState.ACTION:    mob_animation_player.play("Jump")    # or "fall"
		#MobState.ATTACKING: mob_animation_player.play("Attack")
		#Commented out for future implementation. 
		
func attack() -> void:
	if mob_body_state == MobBodyState.IDLE or mob_body_state == MobBodyState.MOVING:
		_set_state(MobBodyState.ATTACKING)
		#animation_player.play("Attack")
		var projectile_instance = projectile.instantiate()
		projectile_instance.global_position = global_position
		projectile_instance.direction = Vector2(-1 if sprite.flip_h else 1, 0)
		get_tree().current_scene.add_child(projectile_instance)
	elif mob_body_state == MobBodyState.ATTACKING:
		print("Already attacking, cannot attack again.")
	elif mob_body_state == MobBodyState.ACTION:
		print("Cannot attack while performing an action.")
	else:
		print("Cannot attack in current state: ", mob_body_state)
func attack() -> void:
	if mob_body_state == MobBodyState.IDLE or mob_body_state == MobBodyState.MOVING:
		_set_state(MobBodyState.ATTACKING)
		#animation_player.play("Attack")
		var projectile_instance = projectile.instantiate()
		projectile_instance.global_position = global_position
		projectile_instance.direction = Vector2(-1 if sprite.flip_h else 1, 0)
		get_tree().current_scene.add_child(projectile_instance)
		start_attack_timer()
	elif mob_body_state == MobBodyState.ATTACKING:
		print("Already attacking, cannot attack again.")
	elif mob_body_state == MobBodyState.ACTION:
		print("Cannot attack while performing an action.")
	else:
		print("Cannot attack in current state: ", mob_body_state)

func start_attack_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = attack_wait_time
	timer.one_shot = true
	timer.timeout.connect(func():
		_on_attack_timeout()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func _on_attack_timeout() -> void:
	_set_state(MobBodyState.IDLE)
