extends RigidBody2D

signal dist_ready(dist: float)

var follow : PathFollow2D = null
var active : bool = false #uses engine
var dist : float = 0.0
var loco : bool = false #can push/pull the train
var force : Vector2 = Vector2(100, 0)
const DRAG_FORCE_SPEED = 30 #velocity where drag is on
const DRAG_FLATNESS = 0.5   #1/X more STRONG ; 1- diagonal ; >1 more flat


func set_follow(new_follow: PathFollow2D):
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
	return Vector2(- vel / DRAG_FLATNESS + DRAG_FORCE_SPEED/DRAG_FLATNESS, 0)

var prev_pos : Vector2 = Vector2.ZERO
func _integrate_forces(state):
	#print("POS:", position, follow.position)
	#calculate next position
	var dir = 1
	#if abs(state.get_constant_force().angle() - follow.rotation) > PI/2:
		#dir = -1
	var vel = state.linear_velocity.length()
	print(name, " ", vel)
	var must_move_dist = vel * state.step * dir
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
	
	#FIXME: small fix for position displacing
	if abs(position.x - follow.position.x) > 1.0:
		position.x = follow.position.x
	if abs(position.y - follow.position.y) > 1.0:
		position.y = follow.position.y
		
	#TODO: calculate correct angular velocity!
	rotation = follow.rotation
	#var orig : Vector2 = state.transform.get_origin()
	

	#apply new force to an active car
	var tot_force : Vector2 = Vector2.ZERO
	if vel > DRAG_FORCE_SPEED:
		tot_force += drag_from_vel(vel)

	if active or not active:
		if Input.is_key_label_pressed(KEY_W):
			tot_force += force
			state.apply_central_force(tot_force.rotated(follow.rotation))
		elif Input.is_key_label_pressed(KEY_S):
			tot_force += force
			state.apply_central_force(tot_force.rotated(PI + follow.rotation))
		else:
			state.apply_central_force(tot_force)
	else:
		#was set_constant_force
		state.apply_central_force(tot_force)
	$Line2D2.points[1] = tot_force
	pass
	
