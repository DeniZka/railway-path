class_name  Train
extends RigidBody2D

signal dist_ready(dist: float)
signal leader_chaned(obj: RigidBody2D)
var path: Path2D
var follow : PathFollow2D = null
var path_progress : float = 0.0 #px

var active : bool = true #uses engine
var dist : float = 0.0
var loco : bool = false #can push/pull the train
var force : Vector2 = Vector2(100, 0)
const DRAG_FORCE_SPEED = 10 #velocity where drag is on
const DRAG_FLATNESS = 300   #moar x - more flat drag

const BREAK_EFFETIVE_SPEED = 200
const BREAK_FLATNESS = BREAK_EFFETIVE_SPEED * 500 #power of breaks. less number significatly moar power. 
var break_state = 0.0  #from 0.0 to 1.0
const DIRECTION_NONE = 0
const DIRECTION_FORWARD = 1
const DIRECTION_BACKWARD = -1
var direction : int = 0

@onready var total_mass : float = mass
var total_force : float = 0.0
var leader : bool = false

var left_cars: Array[Car] = []
var right_cars: Array[Car] = []

func _ready():
	push_right($Car2)

func push_left(car: Car):
	left_cars.append(car)
	#add_child(car)
	
func push_right(car: Car):
	right_cars.append(car)
	#add_child(car)
	
func place_cars():
	var bak_position = follow.position
	var bak_offset = follow.progress
	#set cars from right
	for car in right_cars:
		follow.progress += 24 #calculated between car width
		car.position = follow.position - self.position
		car.rotation = follow.rotation - self.rotation
	#do it
	follow.progress = bak_offset
	pass
	
func set_path(path: Path2D):
	self.path = path
	#create self follow and place it on curve
	var offset = path.curve.get_closest_offset(position)
	follow = PathFollow2D.new()
	path.add_child(follow)
	follow.cubic_interp = false
	follow.progress = offset
	#place self on curve
	self.position = follow.position
	$Car.rotation = follow.rotation
	#self.rotation = follow.rotation

	#place 

func get_engine_force(rudder_pos: float):
	if loco:
		return force * rudder_pos
		
func get_break_strength(break_pos: float):
	pass

func set_leader(yes: bool):
	leader = yes
	leader_chaned.emit(self)

func set_follow(new_follow: PathFollow2D):
	position = new_follow.position
	follow = new_follow
	
func set_dist(new_dist: float):
	dist = new_dist
	
func connect_car(car: String):
	$Joint.node_b = NodePath("../../" + car)

func is_loco():
	return loco
	
func is_active():
	return active
	
func drag_from_vel(vel: float):
	#flat f(x) = - x/DRAG_FLATNESS + DRAG_FORCE/DRAG_FLATNESS
	#parabolic -1/DRAG_FLATNESS *(X-DRAG_FORCE_SPEED)^2
	if vel < DRAG_FORCE_SPEED:
		return Vector2.ZERO
	else :
		return Vector2(- pow(vel - DRAG_FORCE_SPEED, 2)/DRAG_FLATNESS, 0)
		
func set_break(brk: float):
	break_state = brk
	
func break_vel(vel: float):
	#parabolic -1/BRAK_FLAT
	if vel > 0.0001 and vel < BREAK_EFFETIVE_SPEED:
		var result = vel - break_state * pow(vel - BREAK_EFFETIVE_SPEED, 2) / BREAK_FLATNESS
		if result < 0.0:
			return 0.0
		else:
			return result
	else:
		return 0.0 
		
func set_total_mass(tot_mass: float):
	total_mass = tot_mass
	
func set_total_force(tot_force: float):
	total_force = tot_force

var prev_pos : Vector2 = Vector2.ZERO
func _integrate_forces(state):

	
	#print(name, " ", position)
	#print("POS:", position, follow.position)
	#calculate next position
	var dir = 1
	if abs(abs(state.linear_velocity.angle()) - abs(follow.rotation)) > PI/2:
		dir = -1
	var vel = state.linear_velocity.length()

	#FIXME: small fix for position displacing
	
	if abs(position.x - follow.position.x) > 2.0:
		position.x = follow.position.x
		print(name, " X")
		print(name, " vel ", vel)
	if abs(position.y - follow.position.y) > 2.0:
		position.y = follow.position.y
		print(name, " Y")
		#TODO: calculate correct angular velocity!
	$Car.rotation = follow.rotation
	place_cars()
		
	#if name == "Loco":
		#print(name, " Vel: ", state.linear_velocity.angle(), " rot: ", follow.rotation)
	#breaks
	if active:
		vel = break_vel(vel)

	var must_move_dist = vel * state.step * dir
	#print(name, " ", must_move_dist)
	var follow_position = follow.position
	#print(name, " ", must_move_dist)
	follow.progress += must_move_dist
	#change linear_velocity
	var target_dist = (follow.position - follow_position) #FIXME: USE position instead follow_position rice error
	#print("%0.2f, %0.2f" % [must_move_dist, target_dist.length()])
	#print("dist: %0.2f" % (position - prev_pos).length())
	prev_pos = position
	state.linear_velocity = target_dist / state.step
	$Car/Line2D.points[1] = linear_velocity.rotated(-follow.rotation)
	

		

	#var orig : Vector2 = state.transform.get_origin()
	

	#apply new force to an active car
	var tot_force : Vector2 = Vector2.ZERO
	if vel > DRAG_FORCE_SPEED:
		tot_force += drag_from_vel(vel)
		#FIXME: drag direction!!!
	if active:
		if Input.is_key_pressed(KEY_W):
			tot_force += force
			state.apply_central_force(tot_force.rotated(follow.rotation))
		else:
			state.apply_central_force(tot_force.rotated(follow.rotation))
	else:
		#was set_constant_force
		state.apply_central_force(tot_force)
	$Car/Line2D2.points[1] = tot_force
	
	
