extends Area2D
class_name BaseProjectile

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 3.0
@export var sprite: Sprite2D


var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2
var timer := Timer.new()

func _ready() -> void:
	sprite.flip_h = direction.x < 0          # left? flip it.
	_initialize_lifetime_timer()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta


func handle_movement(delta: float) -> void:
	velocity = direction * speed * delta
	self.position += velocity

func _initialize_lifetime_timer() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()



func _on_lifetime_timeout() -> void:
	queue_free()

func _on_body_entered(body:Node2D) -> void:
	body.take_damage(damage)
	queue_free()
