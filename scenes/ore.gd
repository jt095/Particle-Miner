extends CharacterBody2D

const GRID_SIZE = GlobalVars.grid_size
var GRAVITY: int = ProjectSettings.get("physics/2d/default_gravity")
var viewport_rect: Rect2
var parent: Node2D
var is_falling: bool = true
var on_ground: bool = false
var on_conveyor: bool = false
var is_snapped: bool = false
# flag to track collision after motion
var collided: bool = false
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
		
	if should_fall():		
		velocity.y += GRAVITY * delta					
					
	if not viewport_rect.has_point(global_position):
		parent.return_ore_to_pool(self)
		
	# Move the object and handle collisions		
	if not collided:
		var collision = move_and_collide(velocity * delta)
		if collision:		
			collided = true			
			if not is_snapped:
				snap_to_tilemap()			
				is_snapped = true		
			handle_collision(collision.get_collider())
	# initial collision, check for empty below
	else:
		is_snapped = false
		if on_conveyor:
			velocity.x = 25
			move_and_slide()
		if should_fall():		
			if $CollidedTimer.is_stopped():
				$CollidedTimer.start()	
			move_and_slide()		
			
	# Snap to grid after moving	
	if velocity.length() == 0:		
		snap_to_tilemap()		

func handle_collision(collider: Object):
	
	if collider.is_in_group("Ground"):			
		stop()				
		on_ground = true
	if collider.is_in_group("Ore"):		
		if on_ground or on_conveyor:
			return				
		on_conveyor = collider.on_conveyor
		on_ground = collider.on_ground

func snap_to_tilemap():
	# Convert the current position to the closest grid cell in TileMap coordinates
	var map_position = tilemap.local_to_map(position)	
	# Convert back to world position
	var snapped_position = tilemap.map_to_local(map_position)
	# Snap the square's position to the grid in the world	
	position = snapped_position		
	
func stop():
	velocity = Vector2.ZERO

func _on_spawn_timer_timeout():
	$CollisionShape2D.disabled = false	
	
func get_center():
	return Vector2(position.x + GRID_SIZE/2, position.y + GRID_SIZE / 2)
	
func is_landing() -> bool:	
	# Detect if the ore is about to land (colliding with the ground or another square)
	$RayCast2D.target_position = velocity.normalized() * GRID_SIZE*6	
	return $RayCast2D.is_colliding()	
	
func should_fall() -> bool:
	# Detect if the ore is over empty space and therefore should fall
	$EmptyBelowRayCast.target_position = Vector2(0, GRID_SIZE+1)
	return not $EmptyBelowRayCast.is_colliding()

func get_random_color():
	return colors[randi_range(0, len(colors) - 1)]

func _on_collided_timer_timeout():
	collided = false	

func _on_area_2d_body_exited(body):
	if body.is_in_group("Conveyor"):
		on_conveyor = false		


func _on_area_2d_body_entered(body):
	if body.is_in_group("Conveyor"):
		on_conveyor = true			


func _on_reset_conveyor_timer_timeout():
	on_conveyor = true
