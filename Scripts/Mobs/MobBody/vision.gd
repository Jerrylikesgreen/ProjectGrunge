class_name Vision extends Node2D

signal front_body_entered(body: Node2D)
signal front_body_exited(body: Node2D)
signal back_body_entered(body: Node2D)
signal back_body_exited(body: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_vision_front_body_entered(body: Node2D) -> void:
	emit_signal("front_body_entered", body)
	print("front_body_entered")



func _on_vision_front_body_exited(body: Node2D) -> void:
	emit_signal("front_body_exited", body)
	print("front_body_exited")


func _on_vision_back_body_entered(body: Node2D) -> void:
	emit_signal("back_body_entered", body)
	print("Back Entered")


func _on_vision_back_body_exited(body: Node2D) -> void:
	emit_signal("back_body_exited", body)
	print("Back Exit")
	
