extends Area2D

var particle_system_scene = preload("res://scenes/particle_spawner.tscn")

func _ready():
	z_index = 10
	
# This function is called when any input event happens on the Area2D
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var particle_system_scene_instance = particle_system_scene.instantiate()
		particle_system_scene_instance.z_index = 0		
		add_child(particle_system_scene_instance)
