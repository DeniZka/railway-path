class_name Car
extends CollisionShape2D

@export var train_index : int = 0 #place in train -N 0 +N

@export var mass : float = 1.0
@export var has_engine : bool = false
@export var enigne_force : float = 100
@export var width : float = 20
@export var height : float = 12
@export var flip : bool = false

func _ready():
	shape = RectangleShape2D.new()
	shape.size = Vector2(width, height)
