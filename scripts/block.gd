extends Node2D
# custom object to keep track of blocks when in a pile
# Object and coordinates as properties
var obj : RigidBody2D
var x_pos : int
var y_pos : int

func _init(obj: Object, x_pos: int, y_pos: int):
	self.obj = obj
	self.x_pos = x_pos
	self.y_pos = y_pos
