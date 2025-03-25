extends Node2D
const BUILD_GRID_SIZE = GlobalVars.build_grid_size

func _ready():
	$ColorRect.size = Vector2(BUILD_GRID_SIZE, BUILD_GRID_SIZE)
	
func _process(delta):
	position = snapped(Vector2(get_global_mouse_position().x + BUILD_GRID_SIZE / 2, get_global_mouse_position().y + BUILD_GRID_SIZE / 2), Vector2(BUILD_GRID_SIZE, BUILD_GRID_SIZE))	

func _input(event):
	# Hide on mouse button held
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:					
				hide()
			else:
				show()
