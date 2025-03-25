extends Node2D

@onready var tilemap: TileMapLayer = get_parent().get_child(0)

const BUILD_GRID_SIZE = GlobalVars.build_grid_size

# Variables to store the start and end positions of the block
var start_position = Vector2()
var end_position = Vector2()
var is_drawing = false  # Flag to track if we're currently drawing
var block_preview: ColorRect = null  # A ColorRect to show the drawing preview
var conveyor_belt_scene = preload("res://scenes/conveyor_belt.tscn")
var block_cursor_scene = preload("res://scenes/block_cursor.tscn")
var draw_block_preview_scene = preload("res://scenes/draw_block_preview.tscn")
var block_preview_instance = Node2D
var end_block_width: int
var end_block_position: Vector2

func _ready():	
	var block_cursor_instance = block_cursor_scene.instantiate()
	add_child(block_cursor_instance)

func _input(event):
	# Handle mouse button input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Initialize the block preview ColorRect	
				block_preview_instance = draw_block_preview_scene.instantiate()
				add_child(block_preview_instance)
				block_preview_instance.set_rectangle_color(Color(0.0, 0.969, 0.765, 0.8))
				# Start drawing when the mouse is pressed				
				start_position = snapped(Vector2(event.position.x - BUILD_GRID_SIZE / 2, event.position.y - BUILD_GRID_SIZE / 2), Vector2(BUILD_GRID_SIZE, BUILD_GRID_SIZE))
				is_drawing = true
				block_preview_instance.set_rectangle_position(start_position)
				block_preview_instance.set_rectangle_size(Vector2(0,0)) # Reset size
			else:
				# Stop drawing when the mouse is released
				end_position = snapped(Vector2(event.position.x - BUILD_GRID_SIZE / 2, event.position.y - BUILD_GRID_SIZE / 2), Vector2(BUILD_GRID_SIZE, BUILD_GRID_SIZE))
				is_drawing = false
				if block_preview_instance.get_is_valid():
					create_block()  # Finalize the block creation
				block_preview_instance.queue_free()
				

func _process(_delta):
	if is_drawing:
		block_preview_instance.show()
		end_block_width = snapped(abs(get_global_mouse_position().x - start_position.x), BUILD_GRID_SIZE)
		var height = BUILD_GRID_SIZE
		block_preview_instance.set_rectangle_size(Vector2(abs(end_block_width), height))  # Update the preview size
		# Adjust position so the preview starts from the correct point		
		end_block_position = snapped(Vector2(min(start_position.x, get_global_mouse_position().x), start_position.y), Vector2(BUILD_GRID_SIZE, BUILD_GRID_SIZE))			
		block_preview_instance.set_rectangle_position(end_block_position)
		block_preview_instance.set_collision_size(Vector2(abs(end_block_width), height))
		block_preview_instance.set_collision_position(Vector2(end_block_position.x + end_block_width / 2, end_block_position.y + BUILD_GRID_SIZE / 2))					
											
# Function to create the block when mouse is released
func create_block():			
	# Create a StaticBody2D for the block
	var block = conveyor_belt_scene.instantiate()
	block.width = end_block_width
	block.height = BUILD_GRID_SIZE
	if end_position.x < start_position.x:
		block.conveyor_direction = -1
	else:
		block.conveyor_direction = 1
	# Set the position of the block
	block.position = Vector2(end_block_position.x + end_block_width / 2, end_block_position.y + BUILD_GRID_SIZE / 2)
	# Add the block to the scene
	add_child(block)
