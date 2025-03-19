extends RigidBody2D

var sand_size = 4 #area in pixels
var on_conveyor = false
var on_ground = false
var conveyor_speed = 50
var conveyor_direction: int = 1 # direction dictated by conveyor
var viewport_rect: Rect2
var snapped = false
var velocity_threshold = 10
var pile_scene = preload("res://scenes/pile.tscn")
var sand_scene = preload("res://scenes/sand.tscn")
var is_pile_root = true
var centroid

signal add_scene_to_main

func _ready():
	# Create the ground (visual representation)		
	# Get the current camera (if there is one in the scene)
	viewport_rect = get_viewport_rect()
	add_to_group("Sand")	
	gravity_scale = 1
	physics_material_override.friction = 1
	physics_material_override.absorbent = true
	physics_material_override.rough = true
	physics_material_override.bounce = 0
	lock_rotation = false
	mass = 0.01
	contact_monitor = true
	max_contacts_reported = 4		
	angular_damp = 5		
	
	
	var points = [
		Vector2(0,0),
		Vector2(sand_size, 0),
		Vector2(sand_size, sand_size),
		Vector2(0, sand_size)
	]		
	$Polygon2D.polygon = points
	$Polygon2D.color = Color("YELLOW", .9)  # white		
	$CollisionPolygon2D.polygon = points
	# Create the collision shape
	#$CollisionShape2D.shape = RectangleShape2D.new()
	#$CollisionShape2D.shape.extents = Vector2(sand_size/2, sand_size/2)
	
func _physics_process(_delta) -> void:
	# This method is called every physics frame to apply custom physics forces
	# Check if the object is offscreen by comparing its position with the visible rectangle
	if not viewport_rect.has_point(global_position):
		queue_free()  # Delete this object if it's off-screen		
		
	if on_conveyor:
		linear_velocity.x = conveyor_speed * conveyor_direction
	
	#if linear_velocity.x < velocity_threshold and linear_velocity.y < velocity_threshold:
		#call_deferred("snap_to_grid")		
#
	if linear_velocity.y >= velocity_threshold:
		on_conveyor = false	
		on_ground = false		
		call_deferred("unsnap")				

func _on_body_entered(body):
	var new_points: PackedVector2Array
	if body.is_in_group("Sand"):
		if not is_pile_root:
			return
		if (on_ground or on_conveyor) or (body.on_ground or body.on_conveyor):			
			for child in body.get_children():
				if child is Polygon2D:
					if len(child.polygon) > len($Polygon2D.polygon):
						new_points = create_new_points(child, $Polygon2D)
					else:
						new_points = create_new_points($Polygon2D, child)
					
			
			print("Creating new sand")
			queue_free()
			body.queue_free()
			var pos = round_to_grid(global_position)
			call_deferred("create_new_sand", new_points,pos)	
		
		
		if body.on_conveyor:
			on_conveyor = true
			conveyor_direction = body.conveyor_direction
			call_deferred("snap_to_grid")	
		
		if body.on_ground:
			on_conveyor = false
			on_ground = true
			call_deferred("snap_to_grid")	
			
	if body.is_in_group("Conveyor"):
		on_conveyor = true
		call_deferred("snap_to_grid")		
		conveyor_direction = body.direction			
	
	elif body.is_in_group("Ground"):
		on_conveyor = false			
		on_ground = true
		call_deferred("snap_to_grid")		

			
#func apply_push_force(direction: int):
	## Apply a linear velocity
	#linear_velocity = Vector2(direction * move_force, linear_velocity.y)
	
func snap_to_grid():	
	if not snapped:						
		rotation = 0
		lock_rotation = true		
		snapped = true
		
		
func unsnap():
	lock_rotation = false		
	snapped = false
	
func start_pile():
	var pile = pile_scene.instantiate()		
	pile.add_particle(self, Vector2(0,0))
	
func round_to_grid(pos: Vector2):	
	var x = round(pos.x / sand_size) * sand_size
	var y = round(pos.y / sand_size) * sand_size
	var new = Vector2(x, y)	
	return Vector2(x, y)
	
func add_unique_vector(u: Dictionary, v: Vector2):
	if not u.has(v):
		u[v] = true
	
	
func create_new_points(base_polygon: Polygon2D, collider_polygon: Polygon2D):	
	var this_rounded_pos = round_to_grid(base_polygon.global_position)
	var that_rounded_pos = round_to_grid(collider_polygon.global_position)
	print("this:", this_rounded_pos)
	print("that:", that_rounded_pos)
	var diff = this_rounded_pos - that_rounded_pos
	print("Diff:", diff)
	
	# attach left
	if diff.x < 0:
		diff = Vector2(-4, 0)
	# attach right
	elif diff.x > 0:
		diff = Vector2(4, 0)
	# attach on top
	elif diff.y < 0:
		diff = Vector2(0, -4)
	
	# attach below
	elif diff.y > 0:
		diff = Vector2(0, 4)
	# other case
	else:
		diff = Vector2(-4, 0)
	
	var new_points = []	
	
	for point in collider_polygon.polygon:
		point.x += diff.x
		point.y += diff.y
		new_points.append(point)
	print("these points", base_polygon.polygon)
	print("new_points", new_points)
	var merged_points = Geometry2D.merge_polygons(base_polygon.polygon, new_points)
	print("merged_points", merged_points)
	
	return(merged_points[0])
	
			
func combine_with_pile(collider: RigidBody2D):

	var direction_vector: Vector2

	# attach to the right
	if position.x > collider.position.x:	
		direction_vector = Vector2(sand_size, 1)
		
		#shape[0] = shape[0] + Vector2(-2, 0)
		#shape[1] = shape[1] + Vector2(-2, 0)		
		
	# attach to left
	elif position.x < collider.position.x:
		direction_vector = Vector2(-sand_size, 1)
		#shape[2] = shape[2] + Vector2(2, 0)
		#shape[3] = shape[3] + Vector2(2, 0)
		
	# attach above
	elif position.y > collider.position.y:
		direction_vector = Vector2(1, -sand_size)
		#shape[0] = shape[0] + Vector2(0, -2)
		#shape[3] = shape[3] + Vector2(0, -2)
		
	collider.add_particle(self, direction_vector)
	
	



		
		
# Reorders points in counter-clockwise direction using the centroid
func reorder_points(points: Array) -> Array:
	# Calculate the centroid (center of mass) of the polygon
	centroid = Vector2.ZERO
	for point in points:
		centroid += point
	centroid /= points.size()
	# Sort points based on their angle relative to the centroid
	points.sort_custom(_sort_by_angle_with_centroid)
	return points

# Custom sort function to sort points based on angle
func _sort_by_angle_with_centroid(a: Vector2, b: Vector2) -> int:	
	var angle_a = (a - centroid).angle()
	var angle_b = (b - centroid).angle()
	if angle_a < angle_b:
		return -1
	elif angle_a > angle_b:
		return 1
	return 0

		
			
func create_new_sand(new_points: PackedVector2Array, position: Vector2):
	var main_scene = get_tree().root.get_node("Main")	
	var new_sand = sand_scene.instantiate()	
	var poly = Polygon2D.new()
	var col = CollisionPolygon2D.new()
	poly.polygon = new_points
	poly.color = Color("Red")
	col.polygon = new_points
	print(new_points)	
	new_sand.add_child(poly)
	new_sand.add_child(col)
	new_sand.set_global_position(position)
	main_scene.add_child(new_sand)
	
	
	#body.queue_free()
	
	
