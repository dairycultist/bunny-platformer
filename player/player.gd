extends CharacterBody2D
class_name Player

const GRAVITY = 600.0

const WALK_SPEED = 90.0
const WALK_ACCELERATION = 6.5

const RUN_SPEED = 140.0
const RUN_ACCELERATION = 0.3

const BREAKING_ROLL_SPEED = 180.0

const JUMP_VELOCITY = -210.0
const ROLL_JUMP_VELOCITY = -140.0

const ROLL_DRAG = 0.5
const ROLL_BRAKES = 2.0

enum State {
	NORMAL,
	ROLLING
}

@export var level: Level

var state: State

func is_floor_flat() -> bool:
	return get_floor_normal().y < -0.95

func _process(_delta: float) -> void:
	
	$Camera.global_position.y = 0.0

func _physics_process(delta: float) -> void:
	
	level.attempt_collect_at(global_position)
	level.attempt_collect_at(global_position - Vector2(0.0, 8.0))
	
	if state == State.ROLLING and abs(velocity.x) >= BREAKING_ROLL_SPEED:
		
		if level.attempt_break_at(global_position + Vector2(16.0 * sign(velocity.x), 0.0)):
			$Camera.shake()
		
		$Sprite/BreakingRollParticles.emitting = true
		$Sprite/BreakingRollParticles.angle_min = $Sprite.global_rotation_degrees
		$Sprite/BreakingRollParticles.angle_max = $Sprite.global_rotation_degrees
		$Sprite/BreakingRollParticles.color_initial_ramp.set_color(0, Color.from_ok_hsl($Sprite.rotation / PI / 2.0, 1.0, 0.75))
	else:
		$Sprite/BreakingRollParticles.emitting = false
	
	$Step.volume_linear = abs(velocity.x) / RUN_SPEED * 0.8 + 0.2 if is_on_floor() else 0.0
	
	velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("jump"):
		
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif state == State.NORMAL:
			state = State.ROLLING
			velocity.y = ROLL_JUMP_VELOCITY
	
	elif Input.is_action_pressed("crouch"):
		
		if state == State.NORMAL and is_on_floor() and (not is_floor_flat() or abs(velocity.x) > WALK_SPEED):
			state = State.ROLLING
	
	# left/right movement (different depending on rolling or not)
	var direction := Input.get_axis("move_left", "move_right")
	
	match state:
		State.NORMAL:
			
			# when running, you accelerate faster when you're going slower than a walk
			# or changing directions
			if direction:
				if abs(velocity.x) < WALK_SPEED or sign(velocity.x) != sign(direction):
					velocity.x = move_toward(velocity.x, RUN_SPEED * direction, RUN_SPEED * WALK_ACCELERATION * delta)
				else:
					velocity.x = move_toward(velocity.x, RUN_SPEED * direction, RUN_SPEED * RUN_ACCELERATION * delta)
			else:
				velocity.x = lerp(velocity.x, 0.0, WALK_ACCELERATION * delta)
				
		State.ROLLING:
			
			# when rolling, you can slow yourself down whenever, but can only
			# speed yourself up if you're in the air and slower than walk speed
			if direction and not is_on_floor() and abs(velocity.x) < WALK_SPEED:
				velocity.x = move_toward(velocity.x, WALK_SPEED * direction, WALK_SPEED * WALK_ACCELERATION * delta)
			elif direction and sign(velocity.x) != sign(direction):
				velocity = velocity.normalized() * lerp(velocity.length(), 0.0, ROLL_BRAKES * delta)
			else:
				velocity = velocity.normalized() * lerp(velocity.length(), 0.0, ROLL_DRAG * delta)

	var prev_velocity := velocity

	floor_snap_length = abs(velocity.x * delta) + 1.0
	move_and_slide()
	
	# roll physics
	if is_on_floor() and state == State.ROLLING:
		velocity = prev_velocity - get_floor_normal() * (prev_velocity.dot(get_floor_normal()))
		
		# you stop rolling if you're moving slower than a run and either:
		# - you're on a flat surface
		# - you're on a slope but are inputting in the opposite direction of motion
		if velocity.x < RUN_SPEED and (is_floor_flat() or (direction and sign(velocity.x) != sign(direction))):
			state = State.NORMAL
	
	# determine animation
	if abs(velocity.x) > 0.1:
		$Sprite.flip_h = sign(velocity.x) == -1
	
	match state:
		State.NORMAL:
			$Sprite.rotation = 0.0
			if not is_on_floor():
				if Input.is_action_just_pressed("jump"):
					$Animation.play("Jump")
				elif $Animation.current_animation != "Jump":
					$Animation.play("Fall")
			elif direction:
				$Animation.play("Run", -1, abs(velocity.x) * 5.0 / RUN_SPEED + 1.0)
			else:
				$Animation.play("Idle")
		State.ROLLING:
			$Sprite.rotation += velocity.x / 16.0 * delta
			$Animation.play("Roll")
