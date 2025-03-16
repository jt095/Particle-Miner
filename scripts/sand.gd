extends RigidBody2D

var sand_size = 4 #area in pixels
var on_conveyor = false
var on_ground = false
var move_force = 50
var conveyor_direction: int = 1 # direction dictated by conveyor
var viewport_rect: Rect2
var snapped = false

func _ready():
	# Create the ground (visual representation)		
	# Get the current camera (if there is one in the scene)
	viewport_rect = get_viewport_rect()
	self.add_to_group("Sand")	
	self.gravity_scale = 1
	self.physics_material_override.friction = .75
	self.physics_material_override.bounce = 0
	self.lock_rotation = false
	self.mass = 0.01
	self.contact_monitor = true
	self.max_contacts_reported = 4	
	
	#var pin_positions = [
		#Vector2(-(sand_size/2), 0),
		#Vector2(0, -(sand_size/2)),
		#Vector2((sand_size/2), 0),
		#Vector2(0, (sand_size/2))
	#]
	
	#var pin = PinJoint2D.new()
	#add_child(pin)
	#pin.position = pin_positions[i]
	#pin.node_a = self.get_path()
	
	
	#for i in range(0,1):
		#var pin = PinJoint2D.new()
		#add_child(pin)
		#pin.position = pin_positions[i]
		#pin.node_a = self.get_path()
		
	
	var points = [
		Vector2(-(sand_size/2), -(sand_size/2)),
		Vector2(-(sand_size/2), (sand_size/2)),
		Vector2(sand_size/2, sand_size/2),
		Vector2(sand_size/2, -(sand_size/2))
	]		
	$Polygon2D.polygon = points
	$Polygon2D.color = Color("YELLOW", .9)  # white		
	$CollisionPolygon2D.polygon = points
	# Create the collision shape
	
func _physics_process(_delta) -> void:
	# This method is called every physics frame to apply custom physics forces
	# Check if the object is offscreen by comparing its position with the visible rectangle
	if not viewport_rect.has_point(global_position):
		queue_free()  # Delete this object if it's off-screen		
	
	for collider in get_colliding_bodies():		
		if collider.is_in_group("Conveyor"):						
			on_conveyor = true
			call_deferred("snap_to_grid", collider)
			apply_push_force(collider.direction) # Apply force when touching StaticBody2D
			conveyor_direction = collider.direction
		elif collider.is_in_group("Sand") and collider.on_conveyor and linear_velocity.y <= 0.1:					
			on_conveyor = true
			call_deferred("snap_to_grid", collider)			
			apply_push_force(collider.conveyor_direction)
		elif collider.is_in_group("Sand") and collider.on_ground and linear_velocity.y <= 0.1:					
			on_ground = true
			on_conveyor = false
			call_deferred("snap_to_grid", collider)					
		elif collider.is_in_group("Ground"):
			on_ground = true
			on_conveyor = false			
			call_deferred("snap_to_grid", collider)
			constant_force = Vector2(0, 0)
		# moving again
		elif linear_velocity.y >= 3:
			on_ground = false
			on_conveyor = false			
			call_deferred("unsnap")				
			
func apply_push_force(direction: int):
	# Apply a linear velocity
	linear_velocity = Vector2(direction * move_force, linear_velocity.y)
	
func snap_to_grid(collider: Node2D):	
	if not snapped:
		var pos = global_position
		pos.x = round(pos.x / sand_size) * sand_size
		pos.y = round(pos.y / sand_size) * sand_size
		global_position = pos	
		rotation = 0
		lock_rotation = true
		snapped = true
		
func snap_together(collider: RigidBody2D):
	var pin_joint = PinJoint2D.new()
	add_child(pin_joint)
	pin_joint.node_a = self.get_path()
	pin_joint.node_b = collider.get_path()	
		
func unsnap():
	for child in get_children():
		if child is PinJoint2D:
			child.queue_free()
	lock_rotation = false	
	snapped = false
			
