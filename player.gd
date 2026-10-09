extends CharacterBody2D

const WALK_SPEED = 100.0
const WALK_ACCELERATION = 5.0
const RUN_SPEED = 180.0
const RUN_ACCELERATION = 0.1
const JUMP_VELOCITY = -250.0

func _physics_process(delta: float) -> void:
	
	print(abs(velocity.x))
	
	if not is_on_floor():
		velocity.y += 600.0 * delta
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if abs(velocity.x) < WALK_SPEED or sign(velocity.x) != sign(direction):
			velocity.x = move_toward(velocity.x, RUN_SPEED * direction, WALK_SPEED * WALK_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, RUN_SPEED * direction, RUN_SPEED * RUN_ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, WALK_ACCELERATION * delta)

	move_and_slide()
