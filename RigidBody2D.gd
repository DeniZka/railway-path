extends RigidBody2D

var rot : float = 0
var pos : Vector2 = Vector2.ZERO
var force : float = 0

func set_rot(angle: float):
	rot = angle
	
func set_pos(new_pos: Vector2):
	pos = new_pos
	
func add_force(new_force: float):
	force = new_force

func _integrate_forces(state):
	#force
	state.apply_force(Vector2(force,0).rotated(rot))
	#var orig : Vector2 = state.transform.get_origin()
	position = pos
	rotation = rot
	#state.transform = Transform2D(rot, pos)
	
	#Vector2.ZERO.length()
	#print(rot)
	pass
	
