extends Node2D

# Preload the sand system scene
var rock_scene = preload("res://scenes/rock.tscn")
# Preload the BlockDrawer scene
var conveyor_belt_drawer_scene = preload("res://scenes/draw_conveyor_belt.tscn")
var conveyor_belt_drawer_instance: Node2D = null  # The instance of the BlockDrawer scene
var drawing_conveyor = false

func _ready():
	#var sand_scene = get_tree().root.get_node("sand_scene")
	#sand_scene.connect("add_scene_to_main", _on_add_scene_to_main)	
	create_ground([
		Vector2(0, 1030),
		Vector2(0, 1080),
		Vector2(400, 1080),
		Vector2(400, 1030)
	])	
	
	create_ground([
		Vector2(500, 1030),
		Vector2(500, 1080),
		Vector2(1920, 1080),
		Vector2(1920, 1030)
	])	
	create_rock()	
	
#func _on_add_scene_to_main():
	#print("adding pile")
	
func create_rock():
	var rock = rock_scene.instantiate()
	rock.position = Vector2(100, 1000)
	add_child(rock)

func create_ground(points: Array):
	# Create the ground (visual representation)
	var body = StaticBody2D.new()	
	add_child(body)
	body.set_collision_mask_value(2, true)
	var polygon = Polygon2D.new()	
	polygon.polygon = points
	polygon.color = Color(1,1,1)  # white
	body.add_child(polygon)
	
	# Create the collision shape for the ground
	var collision = CollisionPolygon2D.new()
	collision.polygon = points  # Use the same points as the visual polygon	
	body.add_to_group("Ground")
	body.add_child(collision)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.key_label == KEY_B:
			if drawing_conveyor:
				stop_block_drawing()
				drawing_conveyor = false
			else:
				start_block_drawing()
				drawing_conveyor = true
		

func start_block_drawing():
	# If there is no active block drawing instance, create and add it		
	if conveyor_belt_drawer_instance == null:
		conveyor_belt_drawer_instance = conveyor_belt_drawer_scene.instantiate()
		print("new instnace")
		add_child(conveyor_belt_drawer_instance)  # Add the block drawer to the scene		
		print("Block drawing started")
		
func stop_block_drawing():	
	var conveyor_drawer_children = conveyor_belt_drawer_instance.get_children()
	# remove these from the drawer and place into main scene
	for child in conveyor_drawer_children:
		if child.is_in_group("Conveyor"):
			if child.get_parent() != null:
				conveyor_belt_drawer_instance.remove_child(child)
				add_child(child)
	
	conveyor_belt_drawer_instance.queue_free()
	conveyor_belt_drawer_instance = null
	print("Block drawing stopped")	
