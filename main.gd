extends Node2D
#main idea that after cwitch juction rails will reconfiguring self (split /merge paths) after that anounce abount new paths for every train
#after _ready() need to split paths into a parts via junctions
#the most effective way is to flipt path, that does not have any train on it
#NOTE: some paths may be a loop! 

const DIVIDER = 6.0

@onready var path : Path2D = $Path2D
@onready var follow : PathFollow2D = $Path2D/TrainPath
@onready var line : Line2D = $Line2D
@onready var points : Node2D = $DragPoints
@onready var drag_poin_scene : PackedScene = load("res://drag_point.tscn")
@onready var train : Node2D =  $Train
@onready var loco : RigidBody2D = $Train/Loco
@onready var car : RigidBody2D = $Train/Car
var tension = 1.0

func _ready():
	$Train.set_path($Path2D)
	loco.active = true
	#loco.add_collision_exception_with($Train/Car) #TODO: except all in train
	loco.direction = 1
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

func _on_dist_ready(dist: float):
	car.set_dist(dist)
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
	



func _on_spin_box_value_changed(value):
	$Train/Loco.set_break(value)
	pass # Replace with function body.


func _on_option_button_item_selected(index):
	$Train.set_direction(index -1)
	#$Train/Loco.direction = index -1
	pass # Replace with function body.


func _on_flip_curve_pressed():
	var old_curve : Curve2D = $Path2D.curve
	var new_curve : Curve2D = Curve2D.new()
	new_curve.bake_interval = old_curve.bake_interval
	var pos : Vector2
	var _in : Vector2
	var out: Vector2
	for i in range(old_curve.point_count):
		pos = old_curve.get_point_position(i)
		_in = old_curve.get_point_in(i)
		out = old_curve.get_point_out(i)
		new_curve.add_point(pos, out, _in, 0)
	$Path2D.curve = new_curve
	$Train.flip_curve()
