class_name MobBody extends CharacterBody2D
## MobBody class meant to be used by any Movable Game Entety Example - NPC, EnemyMob, Player
## Has Signals sending out data to MobManager that handles Mob Specific logic. 

#------------------------------------------[Signals]------------------------------------------------------------------
## This signals sends out mob_body_state : MobBodyState to Mob Manager to do specifc Mob LLogic on State Changes. 
signal _on_Mob_Body_State_Change(mob_body_state:MobBodyState)
## This signals sends out possition : Vector2 of the current target. 
signal arrived_at_target_pos(pos:Vector2)
## This signals  sends out notice of when Mob Dies for other manager components. 
signal mob_died

#------------------------------------------[Variables]------------------------------------------------------------------------
## Refrence to animation player, this is used to set properties and functions to animate MobBody. 
## Controls the mob’s animations
@onready var animation_player: AnimationPlayer = %AnimationPlayer

## Texture node that shows the mob’s body
@onready var sprite: Sprite2D = %Sprite2D

## Label that displays total health (switch to RichTextLabel later)
@onready var label: Label = %Label

## Allowed distance (px) from the exact target position before we call it “arrived”
const ARRIVE_EPS := 4.0

## Minimum vertical gap (px) between mob and player that will trigger a jump
const JUMP_MIN_DY := 24.0

## Base travel speed of this mob (px / s)
const SPEED := 200.0

## Upward velocity (px/s) applied when the mob jumps
const JUMP_SPEED := 400.0

## Downward acceleration (px/s²) applied every physics frame
const GRAVITY := 900.0

## Horizontal dead-zone: ignore input smaller than this value
const MOVE_EPS := 0.5

## Latest horizontal input  (−1.0 … +1.0)
var _dir: float = 0.0

## Edge-trigger flag set the frame a jump is requested
var _jump: bool = false

## True while the mob is actively moving this frame
var _is_moving: bool = false

## True when the player, not AI, controls this mob
var _is_player_controlled: bool = false

## Last finite state-machine state before the current one
var was_state: MobBodyState = mob_body_state

## Destination for autonomous movement
var target_point: Vector2 = Vector2.ZERO

## Whether a valid target_point is currently set
var has_target: bool = false

## Finite-state machine for high-level behaviour
enum MobBodyState { IDLE, ATTACKING, ACTION, MOVING }

## Current state of the mob’s FSM (shown in the inspector)
@export var mob_body_state: MobBodyState = MobBodyState.IDLE

## Distance (px) at which the mob stops moving toward its target
@export var stop_radius: float = 200.0

## Scene to instance when the mob launches a projectile
@export var projectile: PackedScene

## Seconds the mob waits between consecutive attacks
@export var attack_wait_time: float = 0.5

## Maximum hit-points the mob starts with
@export var health: int = 100

## How many “emotion” points this mob drops on death
@export var emotions_count: int = 10

## Runtime copy of hit-points; decrement this, **not** `health`
var current_health: int = health


#-------------------------[Process]-----------------------------------------------------------------------------------------------------
## Per-frame physics tick: steering, input, gravity / jump, FSM, movement
func _physics_process(delta: float) -> void:
	## Autonomous steering toward the `target_point`
	if has_target:
		_steer_toward_target()

	## Handle player or AI horizontal input
	_apply_input(delta)

	## Apply gravity each frame and perform queued jumps
	_apply_gravity_jump(delta)

	## Advance the finite-state machine (idle → move → attack, etc.)
	_update_state_machine()

	## Move the body and slide against collisions
	move_and_slide()

	## Update the on-screen health read-out every frame
	label.text = str(current_health)

	
#----------------------[Helpers]-------------------------------------------------------------------------------------------

## Queues horizontal movement input (−1.0 = full left, +1.0 = full right)
func set_horizontal_input(dir: float) -> void:
	_dir = clamp(dir, -1.0, 1.0)


## Flags a jump request; processed in `_apply_gravity_jump`
func request_jump() -> void:
	_jump = true

# ────────────────[ Mob-Body State Machine ]────────────────────────────────────

## Applies horizontal input to the mob each physics frame.
## * Moves left/right according to `_dir` (clamped to −1 … +1).  
## * Flips the sprite so the mob faces the direction of travel.  
## * When no input is present, eases velocity.x back to 0 with a snappy decel.
func _apply_input(delta: float) -> void:
	if abs(_dir) > 0.01:
		# Active input → set velocity directly
		velocity.x = _dir * SPEED
		sprite.flip_h = _dir < 0.0          ## Face left if moving left
	else:
		# No input → ease to a stop (4× faster than accel for snappier feel)
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 4.0 * delta)

# ─────────────────────────────[ Physics helpers ]──────────────────────────────

## Handles jump requests and applies gravity every physics tick.
func _apply_gravity_jump(delta: float) -> void:
	if _jump and is_on_floor():
		velocity.y = -JUMP_SPEED              ## launch!
	_jump = false                             ## edge-trigger resets

	if not is_on_floor():                     ## falling / rising
		velocity.y += GRAVITY * delta         ## apply gravity


# ──────────────────────────────[ FSM helpers ]────────────────────────────────

## Decides which high-level state the mob should enter this frame.
func _update_state_machine() -> void:
	var new_state := mob_body_state

	if mob_body_state == MobBodyState.ATTACKING:
		return                                ## lock state until attack ends

	if not is_on_floor():
		new_state = MobBodyState.ACTION
	elif abs(velocity.x) > MOVE_EPS:
		new_state = MobBodyState.MOVING
	else:
		new_state = MobBodyState.IDLE

	_set_state(new_state)


## Switches FSM state, plays matching animation, and emits a change signal.
func _set_state(new_state: MobBodyState) -> void:
	if new_state == mob_body_state:
		return                                ## no change

	mob_body_state = new_state
	_apply_state_animation(mob_body_state)
	emit_signal("_on_Mob_Body_State_Change", mob_body_state)


## Plays the animation that matches the given FSM state.
func _apply_state_animation(s: MobBodyState) -> void:
	match s:
		MobBodyState.IDLE:   animation_player.play("idle")
		MobBodyState.MOVING: animation_player.play("walk")
		# MobBodyState.ACTION:    animation_player.play("jump")   # todo
		# MobBodyState.ATTACKING: animation_player.play("attack") # todo


# ────────────────────────────────[ Combat ]───────────────────────────────────

## Spawns a projectile if the state machine allows an attack.
func attack() -> void:
	if mob_body_state not in [MobBodyState.IDLE, MobBodyState.MOVING]:
		print("Cannot attack in current state: ", mob_body_state)
		return

	_set_state(MobBodyState.ATTACKING)

	var proj := projectile.instantiate()

	var dir    := -1 if sprite.flip_h else 1                  ## −1 left, +1 right
	var offset := sprite.texture.get_size().x * 0.5 + 4.0     ## half-width + margin
	proj.global_position = global_position + Vector2(dir * offset, 0)
	proj.direction       = Vector2(dir, 0)

	## Collision layers / masks swap if mob is player vs enemy
	if is_in_group("Player"):
		proj.collision_layer = 4
		proj.collision_mask  = 2
	elif is_in_group("Enemy"):
		proj.collision_layer = 4
		proj.collision_mask  = 1

	get_tree().current_scene.add_child(proj)
	_start_attack_timer()


## Creates a one-shot timer to end the ATTACKING state after `attack_wait_time`.
func _start_attack_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = attack_wait_time
	timer.one_shot  = true
	timer.timeout.connect(_on_attack_timeout)
	add_child(timer)
	timer.start()


## Callback fired when the attack cooldown finishes.
func _on_attack_timeout() -> void:
	_set_state(MobBodyState.IDLE)


# ────────────────────────────────[ Steering ]─────────────────────────────────

## Sets an autonomous destination for the mob to patrol / chase.
func move_toward_point(point: Vector2) -> void:    ## needed for AI API call
	target_point = point
	has_target   = true


## Basic “arrive” steering toward `target_point`; jumps if needed.
func _steer_toward_target() -> void:
	var d    := target_point - global_position
	var dist := d.length()

	# ───── [ ARRIVE RING ] ────────────────────────────────────────────────
	if dist <= stop_radius:
		has_target = false
		emit_signal("arrived_at_target_pos", target_point)
		set_horizontal_input(0)
		return

	# ───── [ MOVE ] ───────────────────────────────────────────────────────
	set_horizontal_input(signf(d.x))

	## Optional: auto-jump if target is sufficiently higher
	if d.y < -JUMP_MIN_DY and is_on_floor():
		request_jump()


# ───────────────────────────────[ Damage ]────────────────────────────────────

## Reduces health; kills the mob if it reaches zero.
func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()


## Handles death: drops emotions, signals, and frees the node.
func die() -> void:
	if _is_player_controlled:
		pass  ## TODO: game-over logic for player-controlled body
	else:
		Globals.emotions_changed(emotions_count)
		emit_signal("mob_died")
		get_parent().get_parent().queue_free()
