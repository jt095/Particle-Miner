extends RigidBody2D
var block_script = preload("res://scripts/block.gd")
var blocks: Array[Node2D] = []
#var 

func _ready():
	add_to_group("Pile")
	

func add_particle(particle: RigidBody2D, direction: Vector2):	
	var main_scene = particle.get_tree().root.get_node("Main")	
	var new_points: PackedVector2Array
	# first particle in pile
	if len(blocks) == 0:
		for child in particle.get_children():
			if child is Polygon2D:
				$Polygon2D.polygon = child.polygon
				$Polygon2D.color = Color("Blue")
			if child is CollisionPolygon2D:
				$CollisionPolygon2D.polygon = child.polygon
			
		var block = block_script.new(particle, 0, 0)
		blocks.append(block)		
		position = particle.global_position	
		particle.queue_free()	
				
	# add to pile
	else:		
		for child in particle.get_children():
			if child is Polygon2D:
				new_points = child.polygon
		
		# shift by direction
		for p in new_points:
			p *= direction		
			
		var block = block_script.new(particle, direction.x, direction.y)
		blocks.append(block)
		$Polygon2D.polygon += new_points
		$CollisionPolygon2D.polygon += new_points
		particle.queue_free()
		print(blocks)
		
	if not find_parent("Main"):
		main_scene.add_child(self)
		
#func _physics_process(_delta):
	#for collider in get_colliding_bodies():
		#if collider.is_in_group("Pile"):
			#
			#
#func combine_with_pile(collider: RigidBody2D):
#
	#var direction_vector: Vector2
#
	## attach to the right
	#if position.x > collider.position.x:	
		#direction_vector = Vector2(sand_size, 1)
		#
		##shape[0] = shape[0] + Vector2(-2, 0)
		##shape[1] = shape[1] + Vector2(-2, 0)		
		#
	## attach to left
	#elif position.x < collider.position.x:
		#direction_vector = Vector2(-2, 1)
		##shape[2] = shape[2] + Vector2(2, 0)
		##shape[3] = shape[3] + Vector2(2, 0)
		#
	## attach above
	#elif position.y < collider.position.y:
		#direction_vector = Vector2(1, -2)
		##shape[0] = shape[0] + Vector2(0, -2)
		##shape[3] = shape[3] + Vector2(0, -2)
		#
	#collider.add_particle(self, direction_vector)
	#
		
	
