extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func update_score()->void:
	var value = Globals.player_data.current_emotions_count
	var stringify_value = str(value)
	set_text(stringify_value)
