extends Node2D

## Maximum speed at which the particle can fall.
const TERMINAL_VELOCITY = 700
var rock : Area2D

var gravity_val: int = ProjectSettings.get("physics/2d/default_gravity")
@export var size = 4 #px
@export var particle_color = Color.YELLOW
var is_visible = true
var grid_size = GlobalVars.grid_size
var threshold_velocity = 0.1 
var spawn_direction: Vector2
var launch_speed: float
var spawned: bool = false
var min_angle: float = -80.0
var max_angle: float = -60.0
var launch_speed_min: float = 80000.0
var launch_speed_max: float = 71000.0

var velocity = Vector2(0,0)

var on_conveyor: bool = false
var conveyor_direction: int = 0
var conveyor_speed: float = 0
var on_ground: bool = false
var is_falling: bool = true
var is_dropping: bool = false
var is_moving: bool = false
var move_speed: float = 0

var land_position: Vector2
var has_landed: bool = false
var viewport_rect: Rect2
var tried_above: bool = false
var flag_for_swap: bool = false
var drop_veloctiy: float = 4

var search_width_initial: int = 4
var search_height_initial: int = 4
var search_increase_limit: int = 4

func _ready():	
	viewport_rect = get_viewport_rect()
	#var points = [
			#Vector2(0, 0),
			#Vector2(size, 0),
			#Vector2(size, size),
			#Vector2(0, size)
		#]		
	#$Polygon2D.polygon = points
	$Polygon2D.color = Color("Yellow", 1)	
	#var col = CollisionPolygon2D.new()
	#col.polygon = points	
	$Area2D.add_to_group("Particle")	
	#$Area2D.add_child(col)	
	spawn_direction = generate_random_direction()
	launch_speed = randf_range(launch_speed_min, launch_speed_max)		
	$Timer.wait_time = 0.05
	$Timer.one_shot = true
	$Timer.start()
	
	$FallTimer.wait_time = 0.05
	$FallTimer.start()
	for child in get_tree().root.get_node("Main").get_children():
		if child.name == "Rock":
			rock = child
		
			
func _physics_process(delta: float) -> void:
	if not spawned:
		launch(delta)			
		
	if is_falling:
		# Ray cast to find stop position	
		var space_state = get_world_2d().direct_space_state	
		var collision_query = PhysicsRayQueryParameters2D.create(global_position, global_position + velocity)		
		collision_query.collide_with_areas = true	
		collision_query.exclude = [self, rock]	
		var collision_result = space_state.intersect_ray(collision_query)
		if collision_result:
			var pos = collision_result["position"]
			pos.x = snappedf(pos.x, grid_size)
			pos.y = snappedf(pos.y, grid_size) - grid_size / 2
			land_position = pos									
		
	if on_conveyor:		
		velocity.x = conveyor_speed * conveyor_direction * delta
	if is_falling:
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity_val * delta)	
		
	if velocity.length() > 0:
		is_moving = true
	else:
		# If the object stops moving, start the timer to check if it stays stopped		
		if is_moving:
			is_moving = false
			$Timer.start()
			
		
	position += velocity * delta
			
	if not viewport_rect.has_point(global_position):
		queue_free()  # Delete this object if it's off-screen
		print("deleted")		
		
func _process(delta):
	if is_visible:
		$Polygon2D.color = particle_color
	else:
		$Polygon2D.color = Color.DARK_RED
	
func has_overlap():
	print($Area2D.has_overlapping_areas() or $Area2D.has_overlapping_bodies())
	return $Area2D.has_overlapping_areas() or $Area2D.has_overlapping_bodies()
			
func launch(delta: float):		
	var launch_vel = spawn_direction * launch_speed * delta	
	velocity = spawn_direction * launch_speed * delta
	spawned = true	

func generate_random_direction():
	# Generate a random angle in the specified range (in radians)
	var angle = deg_to_rad(randf_range(min_angle, max_angle))
	# Calculate the direction vector from the random angle
	var direction = Vector2(cos(angle), sin(angle))  # Direction vector
	# Apply the force to the Body
	return direction
		
		
func snap(pos: Vector2):				
	global_position = pos	
	velocity = Vector2(0,0)			

func _on_area_2d_body_entered(body):	
	if body.is_in_group("Ground"):			
		snap(land_position)			
		is_falling = false
		#on_ground = true	
		
	if body.is_in_group("Conveyor"):
		snap(land_position)
		is_falling = false
		#on_ground = false
		on_conveyor = true
		conveyor_direction = body.direction
		conveyor_speed = body.conveyor_speed
		
func _on_area_2d_body_exited(body):
	if body.is_in_group("Conveyor"):		
		print("off conveyor")		
		on_conveyor = false
		on_ground = false
		is_falling = true		

func _on_area_2d_area_entered(area):	
	if area.is_in_group("Particle"):
		if on_conveyor or on_ground:
			return		
		var particle = area.get_parent()
		if particle.on_ground or particle.on_conveyor:			
			is_falling = false
			
			if particle.on_ground:		
				snap(land_position)		
				
			if particle.on_conveyor:			
				snap(land_position)						
				conveyor_direction = particle.conveyor_direction
				conveyor_speed = particle.conveyor_speed						


func _on_timer_timeout():
	if velocity.length() == 0:		
		for b in $Area2D.get_overlapping_areas():
			# on top of eachother
			if b.global_position == global_position:	
				is_visible = false									
				print("I shuold move, in same spot as: ", b)				
				var empty_spot = find_empty_spot(1)
				if empty_spot != Vector2(0,0):
					# found an empty spot, reset search for next time					
					global_position = empty_spot					
				else:
					print("No empty spots found, deleting self")
					queue_free()
			else:
				is_visible = true
					
func _on_fall_timer_timeout():	
	if velocity.length() == 0:
		var below = Vector2(global_position.x, global_position.y + grid_size )			
		if not is_occupied(below):	
			print("nothing below me")		
			is_falling = true	
			is_visible = false		
		else:			
			on_ground = true	
			is_visible = true		

# Function to check if a position is occupied
func is_occupied(position: Vector2) -> bool:	
	var space_state = get_world_2d().direct_space_state
	var point_query = PhysicsPointQueryParameters2D.new()
	point_query.collide_with_areas = true
	point_query.position = position
	var query = space_state.intersect_point(point_query)	
	return query.size() > 0  # Returns true if there's a collision (i.e., position is occupied)

# Recursive Function to search for an empty spot
func find_empty_spot(search_radius:int) -> Vector2:			
	print("search_radius:", search_radius)	
	# terminating condition
	if search_radius == search_increase_limit:
		return Vector2(0,0)
		
	var search_vectors = build_search_vectors(search_width_initial + search_radius, search_height_initial + search_radius)
	var search_vector_len = len(search_vectors)
	print("search_vec_len:", search_vector_len)
	var start_position = global_position	
	var attempted_spots = []
	# choose a random position in search_vectors
	var rand_spot = randi_range(0, search_vector_len-1)
	
	# repeat until we've tried all spots
	while len(attempted_spots) < search_vector_len:
		if rand_spot not in attempted_spots:
			attempted_spots.append(rand_spot)			
		else:
			rand_spot = randi_range(0, search_vector_len-1)			
	
		var rand_vec = search_vectors[rand_spot]			
		var target_position = start_position + rand_vec		
		# Check if the target position is free of collisions	
		if not is_occupied(target_position):		
			return target_position  # Return the first empty spot found
				
	# increase the search radius
	return find_empty_spot(search_radius + 1)  # Return null if no empty spot was found


func build_search_vectors(search_width:int, search_height: int) -> Array[Vector2]:
	var vectors: Array[Vector2] = []
	var search_x = search_width * grid_size
	var search_y = search_height * grid_size
		
	for x in range(-search_x, search_x + 1, grid_size):
		for y in range(0, -search_y, -grid_size):
			vectors.append(Vector2(x, y))
	return vectors
