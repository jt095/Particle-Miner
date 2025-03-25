extends Node2D

var is_valid: bool = true
var valid_color: Color
var invalid_color: Color = Color.RED
var area: Area2D

func _ready():
	area = $Area2D
	area.set_monitoring(true)

func _process(_delta):
	#Get all overlapping bodies and areas
	if area == null: return
	var overlapping_bodies = area.get_overlapping_bodies()
	var overlapping_areas = area.get_overlapping_areas()
	overlapping_bodies.erase(self)
	overlapping_areas.erase(area)
	
	if overlapping_bodies.size() > 0 or overlapping_areas.size() > 0:
		set_is_valid(false)
	else:
		set_is_valid(true)
				
	if get_is_valid():
		$ColorRect.color = valid_color
	else:
		$ColorRect.color = invalid_color

func set_rectangle_color(c: Color):
	valid_color = c
	
func set_rectangle_size(s: Vector2):
	$ColorRect.size = s
	
func set_rectangle_position(p: Vector2):
	$ColorRect.position = p

func get_is_valid():
	return is_valid
	
func set_is_valid(v: bool):
	is_valid = v
	
func set_collision_size(s: Vector2):
	$Area2D/CollisionShape2D.shape.size = s
	
func set_collision_position(p: Vector2):
	$Area2D/CollisionShape2D.position = p	
