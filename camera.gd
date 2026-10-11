extends Camera2D

@export var height_in_pixels: float = 13 * 16

var wipe_fac := 0.0
var wipe_to := 0.0

func _ready() -> void:
	
	$Wipe.visible = true
	wipe_out()

func _process(delta: float) -> void:
	
	var c = get_viewport_rect().size.y / height_in_pixels
	
	zoom = Vector2(c, c)
	
	$Wipe.position.y = wipe_fac * wipe_fac * -sign(wipe_fac) * height_in_pixels * 2.0
	wipe_fac = move_toward(wipe_fac, wipe_to, delta)

func wipe_in():
	wipe_fac = -1.0
	wipe_to = 0.0

func wipe_out():
	wipe_fac = 0.0
	wipe_to = 1.0
