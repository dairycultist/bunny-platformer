extends Area2D

var timer := -1.0

var stolen_camera: Camera2D
var stolen_sprite: Sprite2D
var stolen_sprite_velocity: Vector2

func _ready() -> void:
	
	body_entered.connect(func(body: Node2D):
		
		if not body is Player:
			return
		
		$EndLevel.play()
		timer = 0.0
		
		stolen_camera = body.get_node("Camera")
		stolen_camera.position_smoothing_enabled = false
		stolen_camera.reparent(self)
		
		var player_sprite := body.get_node("Sprite")
		stolen_sprite = player_sprite.duplicate()
		add_child(stolen_sprite)
		stolen_sprite.global_position = player_sprite.global_position
		stolen_sprite_velocity = body.velocity
		stolen_sprite.texture = load("res://player/player_roll.png")
		
		body.queue_free()
	)

func _process(delta: float) -> void:
	
	# hover up and down animation
	$Sprite.position.y = sin(Time.get_ticks_msec() / 1000.0) * 3.0
		
	if timer >= 0.0:
		
		stolen_camera.position = lerp(stolen_camera.position, Vector2.ZERO, delta)
		stolen_camera.height_in_pixels *= 1.0 - delta * 0.05
		
		stolen_sprite.position += stolen_sprite_velocity * delta
		stolen_sprite.rotation += 0.02 * stolen_sprite_velocity.x * delta
		stolen_sprite_velocity -= 700.0 * stolen_sprite.position.normalized() * delta
		
		if timer < 1.0 and timer + delta >= 1.0:
			stolen_camera.wipe_in()
		
		if timer < 2.0 and timer + delta >= 2.0:
			get_tree().change_scene_to_file("res://world.tscn")
	
		timer += delta
