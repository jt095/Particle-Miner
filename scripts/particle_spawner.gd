extends Node2D


# Preload the grain scene (to save time)
var sand_scene = preload("res://scenes/sand.tscn")
var particle_scene = preload("res://scenes/particle.tscn")

@export var max_num_grains: int = 10
@export var direction: Vector2 = Vector2(1,1)
var min_force_strength: float = 500.0  # The strength of the force
var max_force_strength: float = 600.0  # The strength of the force
var min_angle: float = -80.0
var max_angle: float = -70.0

func _ready():
	# Create grains of sand with random velocities
	for i in range(randi_range(1,max_num_grains)):
		var grain = particle_scene.instantiate()  # Create a new grain instance
		add_child(grain)  # Add the grain to the scene so it appears
		#grain.apply_force(generate_random_direction() * randf_range(min_force_strength, max_force_strength))
		

func generate_random_direction():
	# Generate a random angle in the specified range (in radians)
	var angle = deg_to_rad(randf_range(min_angle, max_angle))
	# Calculate the direction vector from the random angle
	direction = Vector2(cos(angle), sin(angle))  # Direction vector
	# Apply the force to the Body
	return direction
