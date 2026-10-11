extends TileMapLayer
class_name Level

@export var camera: Camera2D

func _ready() -> void:
	
	# camera limit
	camera.limit_left = get_used_rect().position.x * 16
	camera.limit_right = (get_used_rect().position.x + get_used_rect().size.x) * 16
	
	# collider
	var level_boundary := StaticBody2D.new()
	add_child(level_boundary)
	
	var left_collider := CollisionShape2D.new()
	left_collider.shape = WorldBoundaryShape2D.new()
	left_collider.shape.normal = Vector2(1.0, 0.0)
	left_collider.shape.distance = get_used_rect().position.x * 16
	level_boundary.add_child(left_collider)
	
	var right_collider := CollisionShape2D.new()
	right_collider.shape = WorldBoundaryShape2D.new()
	right_collider.shape.normal = Vector2(-1.0, 0.0)
	right_collider.shape.distance = (get_used_rect().position.x + get_used_rect().size.x) * -16
	level_boundary.add_child(right_collider)

func attempt_collect_at(world_position: Vector2):
	local_to_map(world_position)

func attempt_break_at(world_position: Vector2):
	pass
