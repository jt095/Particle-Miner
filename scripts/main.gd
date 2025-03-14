extends Node2D

# Preload the sand system scene
var sand_system_scene = preload("res://scenes/sand_system.tscn")

# Preload the BlockDrawer scene
var conveyor_belt_drawer_scene = preload("res://scenes/draw_conveyor_belt.tscn")
var conveyor_belt_drawer_instance: Node2D = null  # The instance of the BlockDrawer scene

func _ready():
	create_ground()
	
	var sand_system = sand_system_scene.instantiate()
	add_child(sand_system)		


func create_ground():
	# Create the ground (visual representation)
	var body = StaticBody2D.new()	
	add_child(body)
	var polygon = Polygon2D.new()
	var points = [
		Vector2(0, 1030),
		Vector2(0, 1080),
		Vector2(1920, 1080),
		Vector2(1920, 1030)
	]
	polygon.polygon = points
	polygon.color = Color(0,0,0,)  # white
	body.add_child(polygon)
	
	# Create the collision shape for the ground
	var collision = CollisionPolygon2D.new()
	collision.polygon = points  # Use the same points as the visual polygon
	body.add_child(collision)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.key_label == KEY_B:
			start_block_drawing()

func start_block_drawing():
	# If there is no active block drawing instance, create and add it
	if conveyor_belt_drawer_instance == null:
		conveyor_belt_drawer_instance = conveyor_belt_drawer_scene.instantiate()
		add_child(conveyor_belt_drawer_instance)  # Add the block drawer to the scene
		print("Block drawing started")
	else:
		# If drawing is already active, stop it (optional)
		conveyor_belt_drawer_instance.queue_free()  # Remove the block drawing scene
		conveyor_belt_drawer_instance = null
		print("Block drawing stopped")
