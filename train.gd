class_name Train
extends RigidBody2D
#train calculates it own way into Path and move all carriges along it with them PathFollow
#path updates with new segment from real lines

@export var curve : Curve2D = null:
	set(val):
		curve = val
		path.curve = curve

@onready var path : Path2D = $Path
@onready var cars : Node = $Cars
var lead_loco: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if ! path.curve:
		path.curve = Curve2D.new()
	pass # Replace with function body.
	
func update_path(pos: Vector2, in_: Vector2, out_: Vector2):
	path.curve.add_point(pos, in_, out_)

func attach_car(car : RigidBody2D):
	cars.add_child(car)
	pass

func set_lead_loco(car: RigidBody2D):
	lead_loco = car
	pass

func _integrate_forces(state):
	#print("works")
	pass
