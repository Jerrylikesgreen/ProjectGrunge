class_name MobBody extends CharacterBody2D



enum MobState { IDLE, ATTACKING, ACTION, MOVING }

@export var mob_state: MobState = MobState.IDLE



const SPEED        := 200.0
const JUMP_SPEED   := 400.0           # positive; we negate it when used
const GRAVITY      := 900.0



var _dir : float = 0.0        # horizontal input  (-1 … +1)
var _jump: bool  = false      # edge-trigger flag
var _is_moving := false



@onready var mob_animated_sprite: AnimatedSprite2D = $MobAnimatedSprite
@onready var camera: Camera2D            = $Camera       # if you need it


func set_horizontal_input(dir: float) -> void:
	_dir = clamp(dir, -1.0, 1.0)

func request_jump() -> void:
	_jump = true


func _physics_process(delta: float) -> void:
	if _dir != 0.0:
		velocity.x = _dir * SPEED
		mob_animated_sprite.flip_h = _dir < 0.0          # face movement dir
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * delta * 4)
		
	if _jump and is_on_floor():
		velocity.y = -JUMP_SPEED
	_jump = false
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	move_and_slide()

	# ─── [State machine & animation] ────────────────────────────────────────
	var was_state: MobState = mob_state
	
	if not is_on_floor():
		mob_state = MobState.ACTION
	elif abs(velocity.x) > 0.5:
		mob_state = MobState.MOVING
	else:
		mob_state = MobState.IDLE
		
	if mob_state != was_state:
		_apply_state_animation(mob_state)
		
	_is_moving = abs(velocity.x) > 0.5 or not is_on_floor()
	
func _apply_state_animation(state: MobState) -> void:
	match state:
		MobState.IDLE:      mob_animated_sprite.play("Idle")
		MobState.MOVING:    mob_animated_sprite.play("Walking")
		#MobState.ACTION:    mob_animated_sprite.play("Jump")    # or "fall"
		#MobState.ATTACKING: mob_animated_sprite.play("Attack")
