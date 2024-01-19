class_name RailwayNearestPart
extends RefCounted

var curve: Curve2D = null

func _init(path: Path2D, pre: int, post: int):
	curve = Curve2D.new()
	for i in range(pre, post + 1):
		curve.add_point(
			path.curve.get_point_position(i), 
			path.curve.get_point_in(i),
			path.curve.get_point_out(i)
		)

func append_part(part: RailwayNearestPart) -> bool: #return reverse connection
	
	return false
