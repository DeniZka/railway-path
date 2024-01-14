extends RigidBody2D

signal dist_ready(dist: float)
signal leader_chaned(obj: RigidBody2D)

var path : Path2D =null
var follow : PathFollow2D = null
var active : bool = false #uses engine
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
		#TODO: generate self curve!!!
	#Change follow position after collisions and movements
	#FIX cuve cross section skip!!!
	var clothest_offset = path.curve.get_closest_offset(position)
	if abs(follow.progress - clothest_offset) < 100:
		follow.progress = clothest_offset
		
	#FIX: small fix for position displacing
	if abs(position.x - follow.position.x) > 2.0:
		position.x = follow.position.x
		print(name, " X")
	if abs(position.y - follow.position.y) > 2.0:
		position.y = follow.position.y
		print(name, " Y")
		#TODO: calculate correct angular velocity!
		
		
	var dir = 1
	if abs(abs(state.linear_velocity.angle()) - abs(follow.rotation)) > PI/2:
		dir = -1
	var vel = state.linear_velocity.length()
	#if name == "Loco":
		#print(name, " Vel: ", state.linear_velocity.angle(), " rot: ", follow.rotation)
	#breaks
	if active:
		if break_state > 0.0:
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
	$Line2D.points[1] = linear_velocity.rotated(-follow.rotation)
	
	#TODO: calculate correct angular velocity!
	rotation = follow.rotation
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
	$Line2D2.points[1] = tot_force
	
	#state.integrate_forces()
	#state.integrate_forces()
	#state.integrate_forces()
	
	pass
	
