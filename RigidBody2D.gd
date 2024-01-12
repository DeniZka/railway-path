extends RigidBody2D

var rot : float = 0
var pos : Vector2 = Vector2.ZERO
var force : float = 0

var follow : PathFollow2D = null

func set_follow(new_follow: PathFollow2D):
	follow = new_follow

func set_rot(angle: float):
	rot = angle
	
func set_pos(new_pos: Vector2):
	pos = new_pos
	
func add_force(new_force: float):
	force = new_force

var prev_pos : Vector2 = Vector2.ZERO
func _integrate_forces(state):
	#print("POS:", position, follow.position)
	#calculate next position
	var dir = 1
	#if abs(state.get_constant_force().angle() - follow.rotation) > PI/2:
		#dir = -1
	var must_move_dist : float = state.linear_velocity.length() * state.step * dir
	var follow_position = follow.position
	follow.progress += must_move_dist
	#change linear_velocity
	var target_dist = (follow.position - follow_position) #FIXME: USE position instead follow_position rice error
	#print("%0.2f, %0.2f" % [must_move_dist, target_dist.length()])
	#print("dist: %0.2f" % (position - prev_pos).length())
	prev_pos = position
	state.linear_velocity = target_dist / state.step
	$Line2D.points[1] = linear_velocity
	$Line2D2.points[1] = state.get_constant_force()
	#FIXME: small fix for position displacing
	if abs(position.x - follow.position.x) > 1.0:
		position.x = follow.position.x
	if abs(position.y - follow.position.y) > 1.0:
		position.y = follow.position.y
	#var orig : Vector2 = state.transform.get_origin()
	

	#apply new force
	if Input.is_key_label_pressed(KEY_W):
		state.set_constant_force(Vector2(100,0).rotated(follow.rotation))
	elif Input.is_key_label_pressed(KEY_S):
		state.set_constant_force(Vector2(100,0).rotated(PI + follow.rotation))
	else:
		state.set_constant_force(Vector2.ZERO)
	
	pass
	
