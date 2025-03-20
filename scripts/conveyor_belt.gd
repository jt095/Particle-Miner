extends StaticBody2D

@export var width: float = 1
@export var height: float = 1
@export var conveyor_direction: int = 1
@export var conveyor_speed: float = 100
var friction = 1.0

func _ready():
	add_to_group("Conveyor")
	self.friction = friction
	# Create a collision shape for the block	
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = Vector2(width / 2, abs(height) / 2)  # Half-width and height extended from the middle		
	$CollisionShape2D.one_way_collision = true
	$CollisionShape2D.one_way_collision_margin = 20 # 10px
	
	# Create the color for the block	
	var points = [
		Vector2(-width / 2, -height / 2),
		Vector2(-width / 2,  height / 2),
		Vector2( width / 2,  height / 2),
		Vector2( width / 2, -height / 2)
	]
	$Polygon2D.polygon = points
	$Polygon2D.color = Color(0,0,0)  # black	
