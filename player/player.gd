extends CharacterBody2D

const WALK_SPEED = 100.0
const WALK_ACCELERATION = 3.5
const RUN_SPEED = 180.0
const RUN_ACCELERATION = 0.2
const JUMP_VELOCITY = -210.0
const ROLL_JUMP_VELOCITY = -140.0
const ROLL_DRAG = 0.5
const ROLL_BRAKES = 2.0

enum State {
	NORMAL,
	ROLLING
}

var state: State

func _process(_delta: float) -> void:
	
	$Camera.global_position.y = 0.0

func _physics_process(delta: float) -> void:
	
	$Step.volume_linear = abs(velocity.x) / RUN_SPEED * 0.8 + 0.2 if is_on_floor() else 0.0
	
	velocity.y += 600.0 * delta
	
	if Input.is_action_just_pressed("jump"):
		
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			$Jump.play()
		elif state == State.NORMAL:
			state = State.ROLLING
			velocity.y = ROLL_JUMP_VELOCITY
			$Roll.play()
	
	#elif Input.is_action_just_pressed("ui_down"):
		#if state == State.NORMAL:
			#state = State.ROLLING
	
	# left/right movement (different depending on rolling or not)
	var direction := Input.get_axis("move_left", "move_right")
	
	match state:
		State.NORMAL:
			
			# when running, you accelerate faster when you're going slower than a walk
			if direction:
				if abs(velocity.x) < WALK_SPEED or sign(velocity.x) != sign(direction):
					velocity.x = move_toward(velocity.x, RUN_SPEED * direction, WALK_SPEED * WALK_ACCELERATION * delta)
				else:
					velocity.x = move_toward(velocity.x, RUN_SPEED * direction, RUN_SPEED * RUN_ACCELERATION * delta)
			else:
				velocity.x = lerp(velocity.x, 0.0, WALK_ACCELERATION * delta)
				
		State.ROLLING:
			
			# when rolling, you can slow yourself down whenever, but can only
			# speed yourself up if you're in the air and slower than walk speed
			if direction:
				if not is_on_floor() and abs(velocity.x) < WALK_SPEED:
					velocity.x = move_toward(velocity.x, WALK_SPEED * direction, WALK_SPEED * WALK_ACCELERATION * delta)
				elif sign(velocity.x) != sign(direction):
					velocity = velocity.normalized() * lerp(velocity.length(), 0.0, ROLL_BRAKES * delta)
			else:
				velocity = velocity.normalized() * lerp(velocity.length(), 0.0, ROLL_DRAG * delta)

	var prev_velocity := velocity

	floor_snap_length = abs(velocity.x * delta) + 1.0
	move_and_slide()
	
	# roll physics
	if is_on_floor() and state == State.ROLLING:
		velocity = prev_velocity - get_floor_normal() * (prev_velocity.dot(get_floor_normal()))
		
		if velocity.x < WALK_SPEED and (get_floor_normal() == Vector2.UP or (direction != 0.0 and sign(velocity.x) != sign(direction))):
			state = State.NORMAL
	
	# determine animation
	if abs(velocity.x) > 0.1:
		$Sprite.flip_h = sign(velocity.x) == -1
	
	match state:
		State.NORMAL:
			$Sprite.rotation = 0.0
			if not is_on_floor():
				$Animation.play("Jump")
			elif direction:
				$Animation.play("Run", -1, abs(velocity.x) * 5.0 / RUN_SPEED + 1.0)
			else:
				$Animation.play("Idle")
		State.ROLLING:
			$Sprite.rotation += velocity.x / 16.0 * delta
			$Animation.play("Roll")
