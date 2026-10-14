extends Area2D

@export var next_level: PackedScene = preload("res://level_scenes/level1.tscn")

var timer := -1.0

var stolen_camera: Camera2D
var stolen_sprite: Sprite2D
var stolen_sprite_particles: CPUParticles2D
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
		
		stolen_sprite_particles = stolen_sprite.get_node("BreakingRollParticles")
		stolen_sprite_particles.emitting = true
		
		SaveData.on_end_level(stolen_camera.pb_timer)
		
		body.queue_free()
	)

func _process(delta: float) -> void:
	
	# hover up and down animation
	$PortalSprite.position.y = sin(Time.get_ticks_msec() / 1000.0) * 3.0
	
	if timer >= 0.0:
		
		# this all is a little scuffed but idc
		stolen_camera.position = lerp(stolen_camera.position, Vector2.ZERO, delta)
		stolen_camera.height_in_pixels *= 1.0 - delta * 0.05
		
		stolen_sprite.scale = lerp(stolen_sprite.scale, Vector2.ZERO, delta)
		stolen_sprite.position += stolen_sprite_velocity * delta
		stolen_sprite.rotation += 0.02 * stolen_sprite_velocity.x * delta
		stolen_sprite_velocity -= 700.0 * stolen_sprite.position.normalized() * delta
		stolen_sprite_velocity = lerp(stolen_sprite_velocity, Vector2.ZERO, 1.5 * delta)
		
		stolen_sprite_particles.angle_min = stolen_sprite.global_rotation_degrees
		stolen_sprite_particles.angle_max = stolen_sprite.global_rotation_degrees
		stolen_sprite_particles.scale_amount_min = stolen_sprite.scale.x
		stolen_sprite_particles.scale_amount_max = stolen_sprite.scale.x
		stolen_sprite_particles.color_initial_ramp.set_color(0, Color.from_ok_hsl(Time.get_ticks_msec() / 500.0, 1.0, 0.75))
		
		if timer < 1.0 and timer + delta >= 1.0:
			stolen_camera.wipe_in()
		
		if timer < 2.0 and timer + delta >= 2.0:
			get_tree().change_scene_to_packed(next_level)
	
		timer += delta
