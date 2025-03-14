extends Node2D

# Variables to store the start and end positions of the block
var start_position = Vector2()
var end_position = Vector2()
var is_drawing = false  # Flag to track if we're currently drawing
var block_preview: ColorRect = null  # A ColorRect to show the drawing preview
var block_height = 15 # hard code the height

func _ready():
	# Initialize the block preview ColorRect
	block_preview = ColorRect.new()
	add_child(block_preview)
	block_preview.color = Color(1, 1, 1, 0.5)  # Semi-transparent red for the preview

func _input(event):
	# Handle mouse button input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start drawing when the mouse is pressed				
				start_position = event.position
				is_drawing = true
				block_preview.position = start_position
				block_preview.size = Vector2(0,0) # Reset size
			else:
				# Stop drawing when the mouse is released
				end_position = event.position				
				is_drawing = false
				create_block()  # Finalize the block creation
				block_preview.size = Vector2(0, 0)  # Reset the preview size

func _process(_delta):
	if is_drawing:
		var width = get_global_mouse_position().x - start_position.x
		var height = block_height
		block_preview.size = Vector2(abs(width), abs(height))  # Update the preview size
		# Adjust position so the preview starts from the correct point
		block_preview.position = Vector2(min(start_position.x, get_global_mouse_position().x),
											  min(start_position.y, start_position.y + block_height))

# Function to create the block when mouse is released
func create_block():
	var block_width = end_position.x - start_position.x	
	# Create a StaticBody2D for the block
	var block = StaticBody2D.new()		
	
	# Create a collision shape for the block
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.extents = Vector2(abs(block_width) / 2, abs(block_height) / 2)  # Half-width and height extended from the middle
	collision_shape.shape = rect_shape	
	block.add_child(collision_shape)  # Add the collision shape to the block
	
	
	# Set the position of the block
	block.position = start_position + Vector2(abs(block_width) / 2, abs(block_height) / 2)	
	# Add the block to the scene
	add_child(block)
	
	# Create the color for the block
	var polygon = Polygon2D.new()
	var points = [
		start_position,
		Vector2(start_position.x + block_width, start_position.y),
		Vector2(start_position.x + block_width, start_position.y + block_height),
		Vector2(start_position.x, start_position.y + block_height)
	]
	polygon.polygon = points
	polygon.color = Color(1,1,1)  # white
	add_child(polygon)
