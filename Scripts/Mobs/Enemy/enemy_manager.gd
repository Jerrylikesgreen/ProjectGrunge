class_name EnemyManager extends MobManager                        

signal update_player_score(value:int)

const VISION_SCN := preload("res://Scenes/Body/vision.tscn")

enum EnemyState { IDLE, MOVING, ACTION, ATTACKING, CHASE }

var _state_history : Array[EnemyState] = []
var current_state  : EnemyState        = EnemyState.IDLE : set = _set_state
var _current_target: Vector2           = Vector2.ZERO
var player_ref: Node2D = null    # cache the node
var string_state: String = str(current_state)
var enemy_vision: Node2D= null
@onready var label: Label = $Label

@onready var fsm   : EnemyStateMachine = %EnemyStateMachine



func _ready() -> void:
	mob_body.connect("mob_died", on_mob_died)
	mob_body.has_target    = false
	mob_body.add_to_group("enemy")
	mob_body.set_collision_layer(2)
	mob_body.set_collision_mask(29)
	mob_body.current_health = 30
	if !mob_body._is_player_controled:
		_spawn_vision()
		fsm.explore.connect(_on_explore)
		fsm.chase  .connect(_on_chase)
		fsm.lost_target.connect(_on_lost_target)

func _physics_process(delta: float) -> void:
	if current_state == EnemyState.CHASE and is_instance_valid(player_ref):
		mob_body.move_toward_point(player_ref.global_position)
	if current_state == EnemyState.ATTACKING:
		mob_body.attack()


func _spawn_vision() -> void:
	enemy_vision = VISION_SCN.instantiate()
	mob_body.add_child(enemy_vision)
	enemy_vision.position = Vector2.ZERO 
	enemy_vision.front_body_entered.connect(_on_target_detected)
	enemy_vision.front_body_exited.connect(_on_target_lost)
	enemy_vision.back_body_entered.connect(_flip_sprite)
	enemy_vision.back_body_exited.connect(_on_target_lost)

func _push_history(s: EnemyState, max_len := 20) -> void:
	_state_history.push_back(s)
	if _state_history.size() > max_len:
		_state_history.pop_front()



func _on_target_detected(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		current_state = EnemyState.CHASE

		print("Player found @", body.global_position, body.position)

		mob_body.move_toward_point(_current_target) 
		fsm.on_player_spotted(_current_target)         
		current_state = EnemyState.CHASE

func _on_target_lost(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	print("Lost Player", body)

	_current_target        = Vector2.ZERO
	mob_body.has_target    = false
	current_state          = EnemyState.IDLE
	fsm.on_target_lost()

func _set_state(new_state: EnemyState) -> void:
	if new_state == current_state:

		return
	current_state = new_state
	if new_state == EnemyState.CHASE:
		print("Chasiung!!")
	print("Enemy changed state to", new_state)

func _on_explore() -> void:
	mob_body.has_target = false        # let body idle / patrol

func _on_chase() -> void:
	mob_body.move_toward_point(_current_target)

func _on_lost_target() -> void:
	mob_body.has_target = false

func _on_mob_body_mob_state_changed(new_state: MobBody.MobBodyState) -> void:
	_push_history(EnemyState.values()[int(new_state)])
	print("Enemy Body entered:", str(new_state),
		  "  (history:", _state_history, ")")



func on_mob_died(emotions_count:int) -> void:
	print("Enemy %s died", self.name)
	Globals.emotions_changed(emotions_count)
	print(str(Globals.player_data.current_emotions_count))
	queue_free()


func _on_mob_body_arrived_at_target_pos(pos: Vector2) -> void:
	_set_state(EnemyState.ATTACKING)
	mob_body.attack()
	print("Attack")


func _on_mob_body__on_mob_body_state_change(mob_body_state: MobBody.MobBodyState) -> void:
	if mob_body_state == MobBody.MobBodyState.ATTACKING:
		fsm._set_state(EnemyStateMachine.EnemyState.ATTACKING)
		print("Meeh?")
	pass # Replace with function body.

func _flip_sprite(body)->void:

	if mob_body.sprite.flip_h == false:
		mob_body.sprite.set_flip_h(true)
	else: mob_body.sprite.set_flip_h(false)
	if enemy_vision.rotation == 0.0:
		enemy_vision.set_rotation_degrees(-180.0)
	else: enemy_vision.set_rotation_degrees(0.0)
	
	mob_body._steer_toward_target()

func _on_exit_back() -> void:
	fsm._set_state(EnemyStateMachine.EnemyState.IDLE)

func _on_attacking_state_keep_attacking() -> void:
	mob_body.attack()
	pass # Replace with function body.


func _on_mob_body_mob_died() -> void:
	var value = Globals.player_data.current_emotions_count
	emit_signal("update_player_score", value)
	print(value, "ayay")
	pass # Replace with function body.
