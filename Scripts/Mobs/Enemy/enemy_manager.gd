class_name EnemyManager extends MobManager                        
## Enemy Manager Node. Extends from MobManager that is shared by PlayerManager. .
##
## This Node is meant to be the Observer of the scene. It will handle most signal calls from children. 
## Enemy Manager also emmits signal up tp Level Manager. 
## 
## 
## 
## 
## This signal updates thge player emotions count on hud and also alerts nodes to update / process functions. 
signal update_player_score(value: int)

## Refrence to Vision Scene -> Needed to spwan Vision cones onto child of MobBody 
const VISION_SCN := preload("res://Scenes/Body/vision.tscn")

## Enemy state - Seperet from MobBody State 
enum EnemyState { IDLE, MOVING, ACTION, ATTACKING, CHASE }

## No current use, thought it would be useful to know past states. 
var _state_history : Array[EnemyState] = []

## No current state refrence needed for Enum. 
var current_state  : EnemyState        = EnemyState.IDLE : set = _set_state

## No current state needed as another node sends this Vector2D to Enemy Manager. 
var _current_target: Vector2           = Vector2.ZERO

##Refrence of player for future script use,  cache the node
var player_ref: Node2D = null   
 
## Stored string property? used to display to lable.  Might need to move this to the lable? 
var string_state: String = str(current_state)

## Refrencing vision node to Instatiate on ready. 
var enemy_vision: Node2D= null

## Refrencing lable to set text for Hp display. Might rename and keep in game 
## and change to a rich text lable for nice effects. 
@onready var label: Label = $Label

## Refrence to Enemy State Machine 
@onready var fsm   : EnemyStateMachine = %EnemyStateMachine


## At ready EnemyManager will connect to signal: mob_died from child  MobBody : CharacterBody2D, 
##  has_target is set to false
## MobBody is added to Group enemy and collision/mask layers are set. 
## current_health set to 30
## If !mob_body._is_player_controled Vision cones are spawned. 
## Then signals are connected from state machine. 
func _ready() -> void:
	mob_body.connect("mob_died", on_mob_died)
	mob_body.has_target    = false
	mob_body.add_to_group("enemy")
	mob_body.set_collision_layer(2)
	mob_body.set_collision_mask(29)
	mob_body.current_health = 30
	if !mob_body._is_player_controlled:
		_spawn_vision()
		fsm.explore.connect(_on_explore)
		fsm.chase  .connect(_on_chase)
		fsm.lost_target.connect(_on_lost_target)


## During _physics_process EnemyManager will check current EnemyState then send functions to body depending on state. 
func _physics_process(delta: float) -> void:
	if current_state == EnemyState.CHASE and is_instance_valid(player_ref):
		## If EnemyState is Chase trigers move towards point : Moves towards target. 
		mob_body.move_toward_point(player_ref.global_position)
	if current_state == EnemyState.ATTACKING:
		## If EnemyState is Attacking triggers Attack fuction on MobBody.
		mob_body.attack()


## Used to spawn [vision cones]: Area2d and connects to signals from the vision cones
func _spawn_vision() -> void:
	enemy_vision = VISION_SCN.instantiate()
	mob_body.add_child(enemy_vision)
	enemy_vision.position = Vector2.ZERO 
	enemy_vision.front_body_entered.connect(_on_target_detected)
	enemy_vision.front_body_exited.connect(_on_target_lost)
	enemy_vision.back_body_entered.connect(_flip_sprite)
	enemy_vision.back_body_exited.connect(_on_target_lost)


## Logs state into an array of Max 20. Used to tract states. 
func _push_history(s: EnemyState, max_len := 20) -> void:
	_state_history.push_back(s)
	if _state_history.size() > max_len:
		_state_history.pop_front()

## Receives signal; from MobBody with a body:Node2D when a body enters vision cone. 
func _on_target_detected(body: Node2D) -> void:
	## If body is in group Player, enemy enters EnemyState.Chase and stores refrence of player. 
	if body.is_in_group("player"):
		player_ref = body
		current_state = EnemyState.CHASE
		push_warning("Player found @", body.global_position, body.position)
		mob_body.move_toward_point(_current_target) ##Calls move towards point on MobBody
		fsm.on_player_spotted(_current_target)## passes current target through Enemy State Machine > on_player_spotted()

## Called on signal from MobBody passing thourgh a body:Node2d
func _on_target_lost(body: Node2D) -> void:
	if !body.is_in_group("player"): ## if body is not in group player, we return, ignoring signal. 
		return
	push_warning("Lost Player", body)
	_current_target        = Vector2.ZERO ##Resets current target 
	mob_body.has_target    = false ## sets MobBody has_target to false 
	current_state          = EnemyState.IDLE ## Sets current state to Idle 
	fsm.on_target_lost() ## calls on_target_lost() on EnemyStateMachine to end chase Logic. 

##  Takes new_state: EnemyState and sets it as the current state. 
func _set_state(new_state: EnemyState) -> void:
	if new_state == current_state:
		return## if new state is already currrent state, returns to ignore call. 
	current_state = new_state ## if new state is EnemyState.CHASE currently just pushes warning for debugging. 
	if new_state == EnemyState.CHASE:
		push_warning("Chasiung!!")
	push_warning("Enemy changed state to", new_state)

func _on_explore() -> void:
	mob_body.has_target = false        ## lets body idle / patrol

## Called on signal trggered by StateMachine to run logic for chase.
func _on_chase() -> void:
	mob_body.move_toward_point(_current_target)  

## Called on signal trggered by StateMachine to run logic for when ebnemy losses sight of Target. 
func _on_lost_target() -> void:
	mob_body.has_target = false ##sets mob_body.has_target to false for furture checks. 

## Called by MobBody to log State on  _state_history
func _on_mob_body_mob_state_changed(new_state: MobBody.MobBodyState) -> void:
	_push_history(EnemyState.values()[int(new_state)])
	print("Enemy Body entered:", str(new_state),
		  "  (history:", _state_history, ")")


## Called by MobBody to run dieing logic. 
func on_mob_died() -> void:
	queue_free()

## Called by MobBody when it arrives at target pos thats a ring surronding player to run Attacking logic. 
func _on_mob_body_arrived_at_target_pos(pos: Vector2) -> void:
	_set_state(EnemyState.ATTACKING)## Sets Attacking State
	mob_body.attack()## Calls attack() from MobBody
	push_warning("Attack")

##Called every time mob body stae changes and passes the state. Meant to cycle though a do appopriate logic. 
## I need to refactor some of the other calls to funnel through here. 
func _on_mob_body__on_mob_body_state_change(mob_body_state: MobBody.MobBodyState) -> void:
	if mob_body_state == MobBody.MobBodyState.ATTACKING:
		fsm._set_state(EnemyStateMachine.EnemyState.ATTACKING)

##  Will flip sprite to face player. 
func _flip_sprite(body)->void:

	if mob_body.sprite.flip_h == false:
		mob_body.sprite.set_flip_h(true)
	else: mob_body.sprite.set_flip_h(false)
	if enemy_vision.rotation == 0.0:
		enemy_vision.set_rotation_degrees(-180.0)
	else: enemy_vision.set_rotation_degrees(0.0)
	
	mob_body._steer_toward_target()

## When player leave backl vision sets state to idle. 
func _on_exit_back() -> void:
	fsm._set_state(EnemyStateMachine.EnemyState.IDLE)

## Ensures enemy continues to attack, planning on implementing logic decidfing what to do depending on factors. 
## Examples - if is a ranged mob or if Player already has 2 targets, ect. 
func _on_attacking_state_keep_attacking() -> void:
	mob_body.attack()


## Sends emotions as XP for killing Mobs. Can be used for NPC use aswell when awrding Emotions to player. 
func _on_mob_body_mob_died() -> void:
	var value = Globals.player_data.current_emotions_count
	
	emit_signal("update_player_score", value)
