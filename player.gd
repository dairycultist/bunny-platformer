extends CharacterBody2D

const WALK_SPEED = 100.0
const WALK_ACCELERATION = 3.5
const RUN_SPEED = 180.0
const RUN_ACCELERATION = 0.1
const JUMP_VELOCITY = -180.0
const ROLL_DRAG = 0.8

enum State {
	NORMAL,
	ROLLING
}

var state: State

func _process(delta: float) -> void:
	
	$Camera.global_position.y = 0.0

func _physics_process(delta: float) -> void:
	
	velocity.y += 600.0 * delta
	
	if Input.is_action_just_pressed("ui_up"):
		
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif state == State.NORMAL:
			state = State.ROLLING
	
	elif Input.is_action_just_pressed("ui_down"):
		
		if state == State.NORMAL:
			state = State.ROLLING
	
	# walk
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if state == State.NORMAL:
		if direction:
			if abs(velocity.x) < WALK_SPEED or sign(velocity.x) != sign(direction):
				velocity.x = move_toward(velocity.x, RUN_SPEED * direction, WALK_SPEED * WALK_ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, RUN_SPEED * direction, RUN_SPEED * RUN_ACCELERATION * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, WALK_ACCELERATION * delta)

	var prev_velocity := velocity

	move_and_slide()
	
	# roll
	if is_on_floor() and state == State.ROLLING:
		velocity = prev_velocity - get_floor_normal() * (prev_velocity.dot(get_floor_normal()))
		
		# apply some drag
		velocity = velocity.normalized() * lerp(velocity.length(), 0.0, ROLL_DRAG * delta)
		
		if velocity.x < WALK_SPEED:
			state = State.NORMAL
	
	# determine animation
	$Sprite.flip_h = sign(velocity.x) == -1
	
	match state:
		State.NORMAL:
			$Sprite.rotation = 0.0
			if direction:
				$Animation.play("Run", -1, abs(velocity.x) * 3.0 / RUN_SPEED + 1.0)
			else:
				$Animation.play("Idle")
		State.ROLLING:
			$Sprite.rotation += velocity.x / 16.0 * delta
			$Animation.play("Roll")
