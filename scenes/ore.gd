extends CharacterBody2D

const GRID_SIZE = GlobalVars.grid_size
var GRAVITY: int = ProjectSettings.get("physics/2d/default_gravity")
var is_snapped: bool = false
var viewport_rect: Rect2
var parent: Node2D
var is_falling: bool = true
var on_ground: bool = false

@onready var tilemap: TileMapLayer = get_tree().root.get_node("Main").get_child(0)


func _ready():
	add_to_group("Ore")
	viewport_rect = get_viewport_rect()	
	parent = get_parent()			

func _physics_process(delta):			
	if is_falling:		
		velocity.y += GRAVITY * delta		
	# Move the object and handle collisions	
	var collision = move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision.get_collider())
		# Snap to grid after moving	
	#print(velocity)
	#if velocity.length() == 0:
		#print("here")
		
		
	if not viewport_rect.has_point(global_position):
		parent.return_ore_to_pool(self)

func handle_collision(collider: Object):
	
	if collider.is_in_group("Ground"):		
		snap_to_tilemap()
		is_falling = false
		on_ground = true
	if collider.is_in_group("Ore"):
		if on_ground:
			return
		snap_to_tilemap()		
		print(position)
		if collider.position.x == position.x:	
			print("Centered")
			is_falling = false
			on_ground = true			
		else:
			is_falling = true
			on_ground = false
			
	#if collider.is_in_group("Conveyor"):
		#snap_to_tilemap()
		#velocity.x = collider.conveyor_direction * collider.conveyor_speed
		#move_and_slide()
		#is_falling = false		
		#on_ground = true					

func snap_to_tilemap():
	# Convert the current position to the closest grid cell in TileMap coordinates
	var map_position = tilemap.local_to_map(position)	
	# Convert back to world position
	var snapped_position = tilemap.map_to_local(map_position)
	# Snap the square's position to the grid in the world
	position = snapped_position	
	velocity = Vector2(0,0)

func _on_spawn_timer_timeout():
	$CollisionShape2D.disabled = false
	
func try_falling():
	var below = get_center() + Vector2(0, GRID_SIZE)
	if not is_occupied(below):		
		is_falling = true		
	
func is_occupied(position: Vector2) -> bool:	
	var space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.collide_with_areas = true
	point_query.position = position
	var query = space_state.intersect_point(point_query)	
	return query.size() > 0  # Returns true if there's a collision (i.e., position is occupied)
	
func get_center():
	return Vector2(position.x + GRID_SIZE/2, position.y + GRID_SIZE / 2)
	
func disable_collision_with_other_ore():	
	set_collision_layer_value(2, false)
	
func enable_collision_with_other_ore():	
	set_collision_layer_value(2, true)
