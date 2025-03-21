extends CharacterBody2D

const GRID_SIZE = GlobalVars.grid_size
var GRAVITY: int = ProjectSettings.get("physics/2d/default_gravity")
var viewport_rect: Rect2
var parent: Node2D
var is_falling: bool = true
var on_ground: bool = false
var on_conveyor: bool = false
var is_snapped: bool = false
var search_width_initial = 2
var search_height_initial = 2
var search_increase_limit = 4

var colors: Array[Color] = [Color.GREEN, Color.AQUA, Color.ROYAL_BLUE, Color.BLUE_VIOLET]

var is_in_flight = true  # Whether the ore is in flight (no collision)
var flight_layer = 2  # Collision layer for ores in flight (we'll disable collision with each other)
var ground_layer = 3  # Collision layer for ores on the ground (they should collide with each other)
var flight_mask = 2  # During flight, we don't want to collide with other ores
var ground_mask = 3  # When on the ground, we collide with other ores

@onready var tilemap: TileMapLayer = get_tree().root.get_node("Main").get_child(0)


func _ready():
	add_to_group("Ore")	
	viewport_rect = get_viewport_rect()	
	parent = get_parent()		
	set_collision_layer_value(flight_layer, true)
	set_collision_layer_value(flight_mask, false)	

func _physics_process(delta):		
	# Check if the square is about to land or is already on the ground				
	if is_in_flight and is_landing():		
		# Switch to ground state once it is about to land
		set_collision_layer(ground_layer)
		set_collision_mask(ground_mask)
		is_in_flight = false  # The square is no longer in flight	
	
	if on_conveyor:
		velocity.x = 50
		print(velocity)
		
	if is_falling:		
		velocity.y += GRAVITY * delta		
		# Snap to grid after moving	
		
	if velocity.length() == 0:		
		snap_to_tilemap()		
		if not is_landing():
			is_falling = true
					
	if not viewport_rect.has_point(global_position):
		parent.return_ore_to_pool(self)
		
	# Move the object and handle collisions	
	move_and_slide()
	var collision = get_last_slide_collision()
	if collision:
		if not is_snapped:
			snap_to_tilemap()			
			is_snapped = true		
		handle_collision(collision.get_collider())

func handle_collision(collider: Object):
	
	if collider.is_in_group("Ground"):	
		stop()
		is_falling = false
		on_ground = true
	if collider.is_in_group("Ore"):
		if on_ground or on_conveyor:
			return				
			
		on_ground = collider.on_ground
		on_conveyor = collider.on_conveyor

		if collider.position.x == position.x:							
			is_falling = false			
		else:
			is_falling = true
			on_ground = false			
						
	if collider.is_in_group("Conveyor"):
		on_conveyor = true
		is_falling = false		
		on_ground = true					

func snap_to_tilemap():
	# Convert the current position to the closest grid cell in TileMap coordinates
	var map_position = tilemap.local_to_map(position)	
	# Convert back to world position
	var snapped_position = tilemap.map_to_local(map_position)
	# Snap the square's position to the grid in the world	
	position = snapped_position		
	
func stop():
	velocity = Vector2(0,0)

func _on_spawn_timer_timeout():
	$CollisionShape2D.disabled = false	
	
func get_center():
	return Vector2(position.x + GRID_SIZE/2, position.y + GRID_SIZE / 2)
	
func is_landing() -> bool:	
	# Detect if the ore is about to land (colliding with the ground or another square)
	$RayCast2D.target_position = velocity.normalized() * GRID_SIZE*6	
	return $RayCast2D.is_colliding()	

func get_random_color():
	return colors[randi_range(0, len(colors) - 1)]
