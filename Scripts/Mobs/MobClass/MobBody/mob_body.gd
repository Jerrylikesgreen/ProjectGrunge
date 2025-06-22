extends CharacterBody2D
class_name MobBody

# -----------------------[Signals]------------------------------------------- 
signal mob_state_changed(new_state : MobBodyState)


const SPEED       := 200.0
const JUMP_SPEED  := 400.0
const GRAVITY     := 900.0
const MOVE_EPS    := 0.5

# --------------------------[Members]-------------------------------------- 
@onready var sprite: AnimatedSprite2D = %AnimatedSprite

enum MobBodyState { IDLE, MOVING, ACTION, ATTACKING }

@export var state : MobBodyState = MobBodyState.IDLE : set = _set_state
var _dir     : float = 0.0   ## horizontal input  (-1.0 / +1.0)
var _jump_req: bool  = false ## edge-trigger
var _moving  : bool  = false

# -------------------[Main loop]--------------------------------------------- 
func _physics_process(delta: float) -> void:
	_apply_input(delta)
	_apply_gravity_jump(delta)
	move_and_slide()
	_update_state_machine()

# -------------------------[Input API]--------------------------------------- 
func set_horizontal_input(dir: float) -> void:
	_dir = clamp(dir, -1.0, 1.0)

func request_jump() -> void:
	_jump_req = true

# ----------------------[Internals]------------------------------------------ 
func _apply_input(delta: float) -> void:
	if abs(_dir) > 0.01:
		velocity.x = _dir * SPEED
		sprite.flip_h = _dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 4 * delta)

func _apply_gravity_jump(delta: float) -> void:
	if _jump_req and is_on_floor():
		velocity.y = -JUMP_SPEED
	_jump_req = false
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _update_state_machine() -> void:
	var new_state := state

	if not is_on_floor():
		new_state = MobBodyState.ACTION
	elif abs(velocity.x) > MOVE_EPS:
		new_state = MobBodyState.MOVING
	else:
		new_state = MobBodyState.IDLE

	_set_state(new_state)

func _set_state(new_state : MobBodyState) -> void:
	if new_state == state:
		return                           

	state = new_state
	_apply_state_animation(state)
	emit_signal("mob_state_changed", state)

func _apply_state_animation(s: MobBodyState) -> void:
	match s:
		MobBodyState.IDLE:   sprite.play("Idle")
		MobBodyState.MOVING: sprite.play("Walking")
		#MobBodyState.ACTION: sprite.play("Jump")   ## or “Fall”		#todo: future work
		#MobBodyState.ATTACKING: sprite.play("Attack")					#todo: future work


func move_toward_point(target_pos: Vector2) -> void:
	var dir_vec: Vector2 = target_pos - global_position
	# Walk left/right toward the point
	set_horizontal_input(signf(dir_vec.x))
	#jump 
	if dir_vec.y < -20.0 and is_on_floor():
		request_jump()
