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
var train_mass: float = 0.0
var train_force: float = 0.0

var rudder_pos: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: except cars for cars in train conllision
	if ! path.curve:
		path.curve = Curve2D.new()
	for car in get_children():
		if car is RigidBody2D:
			train_mass += car.mass
			#TODO: set total_mass for every of carrige
			if car.loco:
				train_force += car.force
	pass # Replace with function body.
	
func set_force(level: float):
	rudder_pos = level
	
func update_path(pos: Vector2, in_: Vector2, out_: Vector2):
	path.curve.add_point(pos, in_, out_)

func attach_car(car : RigidBody2D):
	cars.add_child(car)
	pass

func set_lead_loco(car: RigidBody2D):
	lead_loco = car
	pass

func _integrate_forces(state):
	#TODO: Calculate final velocity vector length
	#F/m *dt
	print("works")
	pass
