extends RigidBody2D

var sand_size = 4 #area in pixels
var settled = false
var move_force = 10

func _ready():
	# Create the ground (visual representation)	
	self.gravity_scale = 1
	self.physics_material_override.friction = 1
	self.physics_material_override.bounce = 0.1
	self.physics_material_override.absorbent = true
	self.physics_material_override.rough = true
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
	# Create the collision shape for the ground	
	$CollisionShape2D.shape.size = Vector2(sand_size, sand_size)  # Use the same points as the visual polygon	

func _integrate_forces(state) -> void:
	# This method is called every physics frame to apply custom physics forces
	for collider in get_colliding_bodies():		
		if collider is StaticBody2D:
			print("here")
			apply_push_force() # Apply force when touching StaticBody2D
			
func apply_push_force():
	# Apply a force to move the RigidBody2D when touching the StaticBody2D
	var force = Vector2(move_force, 0) # Force in the x direction (horizontal)
	apply_impulse(force, Vector2.ZERO)  # Apply the impulse at the center of mass
