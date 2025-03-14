extends Node2D


# Preload the grain scene (to save time)
var sand_scene = preload("res://scenes/sand.tscn")

# Number of grains to spawn
var num_grains = 100

func _ready():
	# Create grains of sand at random positions
	for i in range(num_grains):
		var grain = sand_scene.instantiate()  # Create a new grain instance
		# Set random positions within a given area
		grain.position = Vector2(randf_range(900, 1000), randf_range(0, 400))  # Example spawn range
		add_child(grain)  # Add the grain to the scene so it appears
