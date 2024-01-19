class_name RailwaySegment
extends Node2D

signal segment_update_requested(from_point: Vector2, to_point: Vector2)

@onready var path : Path2D = $Path
@onready var follow : PathFollow2D = $Path/PathFollow
@onready var line : Line2D = $Path/Line
var update_dist_sqr: float = -1

func _ready():
	line.default_color = Color(randf(), randf(), randf())

func set_curve(curve: Curve2D):
	#TODO: cache source path and source indeces
	path.curve = curve
	line.points = path.curve.get_baked_points()
	
func correct_position(pos: Vector2):
	var clothest_offset = path.curve.get_closest_offset(pos)
	follow.progress = clothest_offset  
	return follow.position
	
func first_point_position():
	return path.curve.get_point_position(0)
	
func second_point_position():
	return path.curve.get_point_position(1)

func last_point_position():
	return path.curve.get_point_position(path.curve.point_count - 1 )
	
func pre_last_point_position():
	return path.curve.get_point_position(path.curve.point_count - 2 )

func check_edges():
	#clean useless points
	if path.curve.point_count > 2:
		if (second_point_position() - follow.position).length_squared() > update_dist_sqr:
			path.curve.remove_point(0)
		if (pre_last_point_position() - follow.position).length_squared() > update_dist_sqr:
			path.curve.remove_point(path.curve.point_count - 1)
		
	
	#TODO: entered in distance leaved distance
	#TODO: check distance to end points
	if  (first_point_position() - follow.position).length_squared() < update_dist_sqr:
		segment_update_requested.emit(second_point_position(), first_point_position())
	if (last_point_position() - follow.position).length_squared() < update_dist_sqr:
		segment_update_requested.emit(pre_last_point_position(), last_point_position())
		
func add_point(from_point: Vector2, to_point: Vector2, to_in: Vector2, to_out: Vector2):
	if from_point == first_point_position():
		path.curve.add_point(to_point, to_in, to_out, 0)
	else:
		path.curve.add_point(to_point, to_in, to_out)

func get_follow_rotation():
	return follow.rotation
	
func set_update_distance(dist: float):
	update_dist_sqr = pow(dist, 2)
	
func slide_to_distance(dist: float) -> Vector2:
	var pre_position = follow.position
	#print(name, " ", must_move_dist)
	follow.progress += dist
	check_edges()
	#print("fp: ", fp, " fp_: ", follow.progress)
	#print(name, " ", must_move_dist, " ", follow.progress, " ", $Path/PathFollow/Icon2.rotation)
	
	#change linear_velocity
	return (follow.position - pre_position) #FIXME: USE position instead follow_position rice error

