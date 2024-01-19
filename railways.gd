extends Node

signal railwais_ready()

var rails : Array[Path2D] = []
@onready var segment_scene : PackedScene = load("res://railway_segment.tscn")

func parse_railways(railways: Node2D):
	#collect rails paths
	for rail in railways.get_children():
		if rail is Path2D:
			rails.append(rail)
	railwais_ready.emit()
	
func parse_cars(root: Node2D):
	for node in root.get_children():
		if node is Car:
			var segment : RailwaySegment = segment_scene.instantiate()
			add_child(segment)
			segment.set_curve(get_curve_part_from_pos(node.position))
			segment.segment_update_requested.connect(_on_segment_update_requested)
			(node as Car).set_rail_segment(segment)
			
func _on_segment_update_requested(segment: RailwaySegment, from_point: Vector2, to_point: Vector2, to_in: Vector2, to_out: Vector2):
	#TODO check junctions swap curve state
	var curve: Curve2D = null
	for rail in rails:
		curve = rail.curve
		for i in range(curve.point_count):
			if curve.get_point_position(i) == to_point:
				if to_in == curve.get_point_in(i) and to_out == curve.get_point_out(i):
					#direct way
					get_next_point()
				if to_in == curve.get_point_out(i) and to_out == curve.get_point_in(i):
					#reverse way
				
	pass

func add_railways(railway: Path2D):
	rails.append(railway)

func remove_railways(railway: Path2D):
	rails.erase(railway)
	
# nearest point from vector
# {Path: {"pre": pt_idx_0, "post": pt_idx_(0+1)} }

func get_curve_part_from_pos(pos: Vector2):
	#get_nearest path
	var nearest_rail : Path2D = null
	var clothest_offset : float = INF
	for rail in rails:
		var clothest_to_path_offset : float = rail.curve.get_closest_offset(pos)
		if clothest_to_path_offset < clothest_offset:
			clothest_offset = clothest_to_path_offset
			nearest_rail = rail
	
	var most_left_point : int = 0
	var most_right_point : int = nearest_rail.curve.point_count - 1
	for point_idx in range(nearest_rail.curve.point_count):
		var point_offset = nearest_rail.curve.get_closest_offset(nearest_rail.curve.get_point_position(point_idx))
		if point_offset > most_left_point and point_offset < clothest_offset: 
			most_left_point = point_idx
		if point_offset > clothest_offset and point_idx < most_right_point:
			most_right_point = point_idx
		#FIXME: pos == point_idx pos!!!!
	
	#create curve_part
	var curve = Curve2D.new()
	for i in range(most_left_point, most_right_point + 1):
		curve.add_point(
			nearest_rail.curve.get_point_position(i), 
			nearest_rail.curve.get_point_in(i),
			nearest_rail.curve.get_point_out(i)
		)
	return curve
