extends Node2D


# Preload the grain scene (to save time)
var sand_scene = preload("res://scenes/sand.tscn")
var particle_scene = preload("res://scenes/particle.tscn")
var ore_scene = preload("res://scenes/ore.tscn")

# Object Pool for storing squares
var ore_pool = []
var active_ores = []

#init vars from rock
@export var particles_per_spawn: int = 5
# spawn vars
var min_angle: float = -80.0
var max_angle: float = -79
var launch_speed_min: float = 500.0
var launch_speed_max: float = 590.0

func _ready():
	# Create grains of sand with random velocities
	for i in range(randi_range(1,particles_per_spawn)):
		var ore = get_ore_from_pool()
		ore.velocity = launch()		
		add_child(ore)  # Add the grain to the scene so it appears		
		
func get_ore_from_pool() -> CharacterBody2D:
	# Recycle an ore if available in the pool
	if ore_pool.size() > 0:
		return ore_pool.pop_back()
	else:
		return ore_scene.instantiate()
		
func return_ore_to_pool(ore: CharacterBody2D) -> void:
	# Return ore to the pool when no longer needed
	print("deleted:", ore)
	ore_pool.append(ore)
	ore.queue_free()
	
func launch():
	var launch_speed = randf_range(launch_speed_min, launch_speed_max)	
	var spawn_direction = generate_random_direction()
	var launch_vel = spawn_direction * launch_speed	
	return launch_vel
		
func generate_random_direction():
	# Generate a random angle in the specified range (in radians)
	var angle = deg_to_rad(randf_range(min_angle, max_angle))
	# Calculate the direction vector from the random angle
	var direction = Vector2(cos(angle), sin(angle))  # Direction vector
	# Apply the force to the Body
	return direction
