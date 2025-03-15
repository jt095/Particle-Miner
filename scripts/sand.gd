extends RigidBody2D

var sand_size = 4 #area in pixels
var on_conveyor = false
var move_force = 50
var conveyor_direction: int = 1 # direction dictated by conveyor
var viewport_rect: Rect2

func _ready():
	# Create the ground (visual representation)		
	# Get the current camera (if there is one in the scene)
	viewport_rect = get_viewport_rect()
	self.add_to_group("Sand")	
	self.gravity_scale = 1
	self.physics_material_override.friction = 0.5
	self.physics_material_override.bounce = 0	
	self.lock_rotation = false
	self.mass = .1
	self.contact_monitor = true
	self.max_contacts_reported = 4	
	
	
	var points = [
		Vector2(-(sand_size/2), -(sand_size/2)),
		Vector2(-(sand_size/2), (sand_size/2)),
		Vector2(sand_size/2, sand_size/2),
		Vector2(sand_size/2, -(sand_size/2))
	]
	$Polygon2D.polygon = points
	$Polygon2D.color = Color("YELLOW")  # white		
	# Create the collision shape
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = Vector2(sand_size/2, sand_size/2)
	
func _integrate_forces(_state) -> void:
	# This method is called every physics frame to apply custom physics forces
	# Check if the object is offscreen by comparing its position with the visible rectangle
	if not viewport_rect.has_point(global_position):
		queue_free()  # Delete this object if it's off-screen		
	
	for collider in get_colliding_bodies():		
		if collider.is_in_group("Conveyor"):						
			on_conveyor = true
			apply_push_force(collider.direction) # Apply force when touching StaticBody2D
			conveyor_direction = collider.direction
		elif collider.is_in_group("Sand") and collider.on_conveyor and linear_velocity.y <= 0.5:					
			on_conveyor = true
			apply_push_force(collider.conveyor_direction)
		elif collider.is_in_group("Ground"):
			on_conveyor = false
			constant_force = Vector2(0, 0)
		else:
			on_conveyor = false
			constant_force = Vector2(0, 0)
			
func apply_push_force(direction: int):
	# Apply a linear velocity
	linear_velocity = Vector2(direction * move_force, linear_velocity.y)
