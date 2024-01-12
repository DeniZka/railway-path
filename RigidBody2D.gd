extends RigidBody2D

signal dist_ready(dist: float)

var follow : PathFollow2D = null
var active : bool = false
var dist : float = 0.0

func set_follow(new_follow: PathFollow2D):
	follow = new_follow
func set_dist(new_dist: float):
	dist = new_dist
func connect_car(car: String):
	$Joint.node_b = NodePath("../../" + car)


var prev_pos : Vector2 = Vector2.ZERO
func _integrate_forces(state):
	#print("POS:", position, follow.position)
	#calculate next position
	var dir = 1
	#if abs(state.get_constant_force().angle() - follow.rotation) > PI/2:
		#dir = -1
	var must_move_dist = state.linear_velocity.length() * state.step * dir
	var follow_position = follow.position
	print(name, " ", must_move_dist)
	follow.progress += must_move_dist
	#change linear_velocity
	var target_dist = (follow.position - follow_position) #FIXME: USE position instead follow_position rice error
	#print("%0.2f, %0.2f" % [must_move_dist, target_dist.length()])
	#print("dist: %0.2f" % (position - prev_pos).length())
	prev_pos = position
	state.linear_velocity = target_dist / state.step
	$Line2D.points[1] = linear_velocity.rotated(-follow.rotation)
	$Line2D2.points[1] = state.get_constant_force().rotated(-follow.rotation)
	#FIXME: small fix for position displacing
	if abs(position.x - follow.position.x) > 1.0:
		position.x = follow.position.x
	if abs(position.y - follow.position.y) > 1.0:
		position.y = follow.position.y
	rotation = follow.rotation
	#var orig : Vector2 = state.transform.get_origin()
	

	#apply new force to an active car
	if active or not active:
		if Input.is_key_label_pressed(KEY_W):
			state.set_constant_force(Vector2(200,0).rotated(follow.rotation))
		elif Input.is_key_label_pressed(KEY_S):
			state.set_constant_force(Vector2(200,0).rotated(PI + follow.rotation))
		else:
			state.set_constant_force(Vector2.ZERO)
	
	pass
	
