extends RigidBody2D

@export var particles: Array[RigidBody2D] = []
#var 

func add_particle(particle: RigidBody2D):
	# first particle in pile
	if len(particles) == 0:
		for child in get_children():
			if child is Polygon2D:
				$Polygon2D.polygon = child.polygon
				$Polygon2D.color = child.polygon.color
			if child is CollisionPolygon2D:
				$CollisionPolygon2D.polygon = child.polygon				
				
	# add to pile
	#else:
		
		
	particles.append(particle)
	
