extends Node2D

const DIVIDER = 6.0

@onready var path : Path2D = $Path2D
@onready var follow : PathFollow2D = $Path2D/PathFollow2D
@onready var line : Line2D = $Line2D
@onready var points : Node2D = $DragPoints
@onready var drag_poin_scene : PackedScene = load("res://drag_point.tscn")
var tension = 1.0

func _ready():
	var in_ : Vector2 = path.curve.get_point_in(0)
	var pt2 : Vector2 = $Path2D.curve.get_point_position(2)
	var pt2i : Vector2= $Path2D.curve.get_point_in(2)
	var pt2o : Vector2= $Path2D.curve.get_point_out(2)
	$Path2D.curve.add_point(pt2, Vector2.ZERO, Vector2.ZERO, 3)
	$Path2D.curve.set_point_in(3, pt2i)
	$Path2D.curve.set_point_out(3, pt2o)
	
	$Path2D.curve.add_point(pt2, Vector2.ZERO, Vector2.ZERO, 2)
	$Path2D.curve.set_point_in(2, pt2i)
	$Path2D.curve.set_point_out(2, pt2o)
	
	#$Path2D.curve.set_point_position(3, Vector2.INF)
	$Line2D.points = $Path2D.curve.get_baked_points()
	
	
	line.points = path.curve.get_baked_points()
	for i in range(path.curve.point_count):
		if path.curve.get_point_position(i) != Vector2.INF:
			var point : DragPoint = drag_poin_scene.instantiate()
			points.add_child(point)
			point.set_index(i)
			point.my_set_position(path.curve.get_point_position(i))
			point.point_moved.connect(_on_point_moved)
		
		
func _physics_process(delta):
	
	var rot = $Path2D/PathFollow2D.rotation
	$RigidBody2D.set_rot(rot)

	var vel_dist : float = 0
	#if $RigidBody2D.constant_force.length_squared() > 0:
	vel_dist = $RigidBody2D.linear_velocity.length()
	#elif $RigidBody2D.constant_force.length_squared() < 0: 
	vel_dist = -$RigidBody2D.linear_velocity.length()
	follow.progress += vel_dist * delta
	$RigidBody2D.set_pos(follow.position)
	if Input.is_key_label_pressed(KEY_UP):
		$RigidBody2D.add_force(1000)
		#$RigidBody2D.apply_force(Vector2(1000, 0).rotated(rot))
		#$RigidBody2D2.apply_force(Vector2(1000, 0).rotated(rot))
	if Input.is_key_label_pressed(KEY_A):
		$RigidBody2D2.apply_torque(1000)
	
	
func _process(delta):
	#follow.progress += delta * 20
	#print(follow.progress)
	pass

func _input(event):
	#if event is InputEventKey:
		#if event.keycode == KEY_W:
			#if event.pressed:
				#$RigidBody2D.add_force(100)
			#else:
				#$RigidBody2D.add_force(0)
		#if event.keycode == KEY_S:
			#if event.pressed:
				#$RigidBody2D.add_force(-100)
			#else:
				#$RigidBody2D.add_force(0)
	pass

func _on_point_moved(idx: int, pos: Vector2):
	path.curve.set_point_position(idx, pos)
	#TODO: recalculate inputs and outputs
	var p0 : Vector2 = Vector2.INF
	var p0_virt : bool = false
	var p2 : Vector2 = Vector2.INF
	var p2_virt : bool = false
	if idx > 0:
		p0 = path.curve.get_point_position(idx-1)
	var p1 = pos
	if idx < path.curve.point_count -1:
		p2 = path.curve.get_point_position(idx+1)
	#calculate virtual points if drag end
	if p0 == Vector2.INF:
		p0_virt = true
		p0 = p1 - p2 + p1
	if p2 == Vector2.INF:
		p2_virt = true
		p2 = p1 - p0 + p1
	#move in_out
	path.curve.set_point_out(idx, (p2-p0)/(DIVIDER * tension) )
	path.curve.set_point_in(idx, -(p2-p0)/(DIVIDER * tension) )
	
	if not p0_virt:
		if idx > 1: #p0 - first
			var p0io : Vector2 = (p1 - path.curve.get_point_position(idx-2))/(DIVIDER * tension)
			path.curve.set_point_out(idx-1, p0io)
			path.curve.set_point_in(idx-1, -p0io)
		else:
			var prep0io : Vector2 = (p1-p0) / (DIVIDER/2*tension)
			path.curve.set_point_out(idx-1, prep0io)
	
	if not p2_virt:
		if idx < path.curve.point_count - 2:  #p2 - last
			var p2io : Vector2 = (path.curve.get_point_position(idx+2) - p1)/(DIVIDER * tension)
			path.curve.set_point_out(idx+1, p2io)
			path.curve.set_point_in(idx+1, -p2io)
		else:
			var prostp2io : Vector2 = (p2 - p1) / (DIVIDER/2*tension)
			path.curve.set_point_in(idx+1, -prostp2io)
	
		
	
	line.points = path.curve.get_baked_points()
	

