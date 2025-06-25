extends ColorRect

@onready var mat := material    # cache for speed

func _ready() -> void:
	_on_desat_changed(Globals.screen_desat)
	Globals.connect("screen_desat_changed", _on_desat_changed)

func _on_desat_changed(val: float) -> void:
	mat.set_shader_parameter("desat", val)
