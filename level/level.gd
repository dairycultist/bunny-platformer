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

func attempt_collect_at(world_position: Vector2) -> bool:
	
	var cell_position := local_to_map(world_position)
	var id := get_cell_source_id(cell_position)
	
	if id == 2: # id of carrots
		set_cell(cell_position)
		$Carrot.play()
		$CollectableParticle.position = map_to_local(cell_position)
		$CollectableParticle.emitting = true
		return true
	
	return false

func attempt_break_at(world_position: Vector2) -> bool:
	
	var cell_position := local_to_map(world_position)
	var id := get_cell_source_id(cell_position)
	
	if id == 1: # id of breakables
		set_cell(cell_position)
		$BreakBlock.play()
		$BreakingBlockParticles.position = map_to_local(cell_position)
		$BreakingBlockParticles.emitting = true
		return true
	
	return false
