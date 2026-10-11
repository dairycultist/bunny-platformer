extends Area2D

var edge := -1
var timer := -2.0

var stolen_camera: Camera2D
var stolen_sprite: Sprite2D
var stolen_sprite_velocity: Vector2

func _ready() -> void:
	
	$Wipe.visible = true
	
	body_entered.connect(func(body: Node2D):
		
		if not body is Player:
			return
		
		$EndLevel.play()
		$Wipe.visible = true
		edge = 1
		timer = 0.1
		
		stolen_camera = body.get_node("Camera")
		stolen_camera.position_smoothing_enabled = false
		stolen_camera.reparent(self)
		
		var player_sprite := body.get_node("Sprite")
		stolen_sprite = player_sprite.duplicate()
		stolen_sprite.global_position = player_sprite.global_position
		stolen_sprite_velocity = body.velocity
		stolen_sprite.texture = load("res://player/player_roll.png")
		add_child(stolen_sprite)
		
		body.queue_free()
	)

func _process(delta: float) -> void:
	
	# hover up and down animation
	$Sprite.position.y = sin(Time.get_ticks_msec() / 1000.0) * 3.0
	
	if sign(timer) == edge:
		
		$Wipe.position.y = edge * pow((2.0 - abs(timer)) / 2.0 * 4.0, 2.0) * 100.0
		
		if edge == 1:
			
			stolen_camera.position = lerp(stolen_camera.position, Vector2.ZERO, delta)
			stolen_camera.height_in_pixels *= 1.0 - delta * 0.05
			
			stolen_sprite.position += stolen_sprite_velocity * delta
			stolen_sprite.rotation += 0.02 * stolen_sprite_velocity.x * delta
			stolen_sprite_velocity -= 700.0 * stolen_sprite.position.normalized() * delta
			
			if timer < 2.0 and timer + delta >= 2.0:
				get_tree().change_scene_to_file("res://world.tscn")
		
		timer += delta
