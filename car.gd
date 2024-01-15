class_name Car
extends RigidBody2D

#TODO: due to collision send signal to train
signal velocity_changed(car: RigidBody2D, new_velocity: Vector2)
signal velocity_stabilized(car: RigidBody2D, new_velocity: Vector2)

signal dist_ready(dist: float)
signal leader_chaned(obj: RigidBody2D)

@export var flip : bool = false #flip rotation 10+pi
@export var direction : int = -1


var path : Path2D =null
var follow : PathFollow2D = null
var active : bool = false #uses engine
var dist : float = 0.0
@export var loco : bool = false #can push/pull the train
@export var engine_force : float = 100.0
var throttle_level : float = 0.0
const DRAG_FORCE_SPEED = 10 #velocity where drag is on
const DRAG_FLATNESS = 300   #moar x - more flat drag

const BREAK_EFFETIVE_SPEED = 200
const BREAK_FLATNESS = BREAK_EFFETIVE_SPEED * 500 #power of breaks. less number significatly moar power. 
var break_state = 0.0  #from 0.0 to 1.0
const DIRECTION_NONE = 0
const DIRECTION_FORWARD = 1
const DIRECTION_BACKWARD = -1

@onready var total_mass : float = mass
var bak_mass : float = 0.0
var total_force : float = 0.0
var leader : bool = false
var train_force_part : float = 0.0

func _ready():
	self.follow = PathFollow2D.new()
	self.follow.cubic_interp = false #NOTE: moar smooth move
	follow.position = position

func set_leader(yes: bool):
	leader = yes
	leader_chaned.emit(self)

func set_follow(new_follow: PathFollow2D):
	position = new_follow.position
	rotation = new_follow.rotation + int(flip) * PI
	follow = new_follow
	
func get_follow():
	return self.follow
	
func set_dist(new_dist: float):
	dist = new_dist
	
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
	
func set_train_mass(train_mass: float):
	#bak_mass = mass
	#mass = train_mass
	pass
	
func reset_train_mass():
	#mass = bak_mass
	pass

func get_engine_force(throttle_pos: float):
	return engine_force * throttle_pos
		
func get_main_loco_dir():
	if flip:
		return direction * -1.0
	else:
		return direction
		
func set_train_force_part(force: float):
	train_force_part = force

var prev_pos : Vector2 = Vector2.ZERO
func _integrate_forces(state):
		#TODO: generate self curve!!!
	#Change follow position after collisions and movements
	var clothest_offset = path.curve.get_closest_offset(position)
	if abs(follow.progress - clothest_offset) < 100: #FIX curve cross /near section skip!!!
		follow.progress = clothest_offset
		position = follow.position
		
	#FIX: small fix for position displacing
	if abs(position.x - follow.position.x) > 1.0:
		position.x = follow.position.x
		print(name, " X")
	if abs(position.y - follow.position.y) > 1.0:
		position.y = follow.position.y
		print(name, " Y")
		#TODO: calculate correct angular velocity!
		
	#TODO: calculate correct angular velocity!
	rotation = follow.rotation + int(flip) * PI
		
	#TODO: correctly calculate direction forward the line or backward
	var dir = 1
	if abs(state.linear_velocity.angle_to(Vector2.RIGHT.rotated(rotation))) > PI/2:
		dir = -1
	if flip:
		dir *= -1
	
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
	

	#var orig : Vector2 = state.transform.get_origin()
	$Line2D.points[1] = linear_velocity.rotated(-rotation)
	

	#apply new force to an active car
	var tot_force : Vector2 = Vector2.ZERO
	#if vel > DRAG_FORCE_SPEED:
		#tot_force += drag_from_vel(vel)
		#FIXME: drag direction!!!
	tot_force += Vector2(train_force_part, 0)
	state.apply_central_force(tot_force.rotated(follow.rotation))
	$Line2D2.points[1] = tot_force.rotated(rotation)
	
	#state.integrate_forces()
	
func _physics_process(delta):
	#print(name, " - ", linear_velocity)
	pass


func _on_body_entered(body):
	velocity_changed.emit(self, linear_velocity)


func _on_body_exited(body):
	velocity_stabilized.emit(self, linear_velocity)
