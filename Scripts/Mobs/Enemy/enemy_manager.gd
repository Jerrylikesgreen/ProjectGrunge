class_name EnemyManager extends MobManager                        


const VISION_SCN := preload("res://Scenes/Body/vision.tscn")

enum EnemyState { IDLE, MOVING, ACTION, ATTACKING, CHASE }

var _state_history : Array[EnemyState] = []
var current_state  : EnemyState        = EnemyState.IDLE : set = _set_state
var _current_target: Vector2           = Vector2.ZERO


@onready var fsm   : EnemyStateMachine = %EnemyStateMachine
var       vision   : Area2D            = null


func _ready() -> void:
	_spawn_vision()


func _spawn_vision() -> void:
	vision = VISION_SCN.instantiate()
	add_child(vision)

	vision.body_entered.connect(_on_target_detected)
	vision.body_exited .connect(_on_target_lost)




func _push_history(s: EnemyState, max_len := 20) -> void:
	_state_history.push_back(s)
	if _state_history.size() > max_len:
		_state_history.pop_front()

func _on_target_detected(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	print("Player found @", body.global_position)

	_current_target = body.global_position
	mob_body.move_toward_point(_current_target)
	fsm.on_player_target() 
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
	print("Enemy changed state to", new_state)


func _on_mob_body_mob_state_changed(new_state: MobBody.MobBodyState) -> void:
	_push_history(EnemyState.values()[int(new_state)])
	print("Enemy Body entered:", new_state,
		  "  (history:", _state_history, ")")
