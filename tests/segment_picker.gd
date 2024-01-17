class_name SegmentPicker
extends Node2D


enum{MODE_IDLE, MODE_DRAG}
var mode = MODE_IDLE
var index = 0
var paths : Array[Path2D]

signal point_moved(idx: int, pos: Vector2)


func set_index(idx: int):
	index = idx
	
func add_path(path: Path2D):
	paths.append(path)
	
func get_nearest_path():
	var nearest_path = null
	var clothest_offset : float = INF
	for path in paths:
		var clothest_to_path_offset : float = path.curve.get_closest_offset($Segment_picker.position)
		if clothest_to_path_offset < clothest_offset:
			clothest_offset = clothest_to_path_offset
			nearest_path = path
	return [nearest_path, clothest_offset]
	
func get_clothest_points():
	var path_offset : Array = get_nearest_path()
	var path : Path2D = path_offset[0]
	var offset : float = path_offset[1]
	var most_left_point : int = 0
	var most_right_point : int = path.curve.point_count - 1
	for point_idx in range(path.curve.point_count):
		var point_offset = path.curve.get_closest_offset(path.curve.get_point_position(point_idx))
		if point_offset > most_left_point and point_offset < offset: 
			most_left_point = point_idx
		if point_offset > offset and point_idx < most_right_point:
			most_right_point = point_idx
	return [most_left_point, most_right_point, path]
	
func _process(delta):
	if paths.size() > 0:
		var pts = get_clothest_points()
		var path : Path2D = pts[2]
		$Path2D.curve.set_point_position(0, path.curve.get_point_position(pts[0]))
		$Path2D.curve.set_point_position(1, path.curve.get_point_position(pts[1]))
		$Path2D.curve.set_point_in(1, path.curve.get_point_in(pts[1]))
		$Path2D.curve.set_point_in(0, path.curve.get_point_in(pts[0]))
		$Path2D.curve.set_point_out(0, path.curve.get_point_out(pts[0]))
		$Path2D.curve.set_point_out(1, path.curve.get_point_out(pts[1]))
		$Line2D.points = $Path2D.curve.get_baked_points()

func _input(event):
	if event is InputEventMouseMotion and mode == MODE_DRAG:
		my_set_position(get_global_mouse_position())
		
func my_set_position(new_position: Vector2):
	$Segment_picker.position = new_position
	point_moved.emit(index, new_position)

func _on_segment_picker_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mode = MODE_DRAG
		if event.button_index == MOUSE_BUTTON_LEFT and (not event.pressed):
			mode = MODE_IDLE
