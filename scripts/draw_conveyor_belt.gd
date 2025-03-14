extends Node2D

# Variables to store the start and end positions of the block
var start_position = Vector2()
var end_position = Vector2()
var is_drawing = false  # Flag to track if we're currently drawing
var block_preview: ColorRect = null  # A ColorRect to show the drawing preview
var block_height = 15 # hard code the height
var conveyor_belt_scene = preload("res://scenes/conveyor_belt.tscn")

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
	var block_width = abs(end_position.x - start_position.x)	
	# Create a StaticBody2D for the block
	var block = conveyor_belt_scene.instantiate()
	block.width = block_width
	block.height = block_height	
	if end_position.x < start_position.x:
		block.direction = -1
	else:
		block.direction = 1
	# Set the position of the block
	block.position = start_position + Vector2(sign(end_position.x - start_position.x)*block_width/2, abs(block_height) / 2)	
	# Add the block to the scene
	add_child(block)
