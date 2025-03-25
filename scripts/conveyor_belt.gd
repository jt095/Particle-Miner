extends StaticBody2D

@export var width: int
@export var height: int
@export var conveyor_direction: int = 1
@export var conveyor_speed: int = 100
var friction = 1.0

func _ready():
	add_to_group("Conveyor")
	self.friction = friction
	# Create a collision shape for the block		
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = Vector2(width, height)  # Half-width and height extended from the middle		
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
