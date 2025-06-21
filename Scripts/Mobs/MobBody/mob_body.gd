class_name MobBody extends CharacterBody2D

#------------------------------------------[Signals]------------------------------------------------------------------
signal _on_Mob_Body_State_Change(mob_body_state:MobBodyState)



#------------------------------------------[Variables]------------------------------------------------------------------------
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite


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



#-------------------------[Process]-----------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	_apply_input(delta)
	_apply_gravity_jump(delta)
	move_and_slide()
	_update_state_machine()
	
#----------------------[Helpers]-------------------------------------------------------------------------------------------
func set_horizontal_input(dir: float) -> void:
	_dir = clamp(dir, -1.0, 1.0)

func request_jump() -> void:
	_jump = true


#--------------[Mob Body State Machine]--------------------------------------------------------------------



func _apply_input(delta: float) -> void:
	if abs(_dir) > 0.01:
		velocity.x = _dir * SPEED
		animated_sprite.flip_h = _dir < 0.0
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
		MobBodyState.IDLE:   animated_sprite.play("Idle")
		MobBodyState.MOVING: animated_sprite.play("Walking")
		#MobState.ACTION:    mob_animated_sprite.play("Jump")    # or "fall"
		#MobState.ATTACKING: mob_animated_sprite.play("Attack")
		#Commented out for future implementation. 
		
