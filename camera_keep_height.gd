extends Camera2D

@export var height_in_pixels: float = 13 * 16

func _process(_delta: float) -> void:
	
	var c = get_viewport_rect().size.y / height_in_pixels
	
	zoom = Vector2(c, c)
