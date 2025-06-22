extends Area2D
class_name BaseProjectile

@export var speed: float = 400.0
@export var damage: int = 1
@export var lifetime: float = 3.0
@export var sprite: Sprite2D

var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2

func _ready() -> void:
	if direction == Vector2.LEFT:
		sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		sprite.flip_h = false
	initialize_lifetime_timer()

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	velocity = direction * speed * delta
	position += velocity

func initialize_lifetime_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_timeout)
	add_child(timer)
	timer.start()

func _on_lifetime_timeout() -> void:
	queue_free()

func _on_body_entered(body:Node2D) -> void:
	body.take_damage(damage)
	queue_free()
