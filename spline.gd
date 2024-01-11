@tool
extends Line2D

var virtual_start: Vector2 = Vector2.ZERO
var virtual_end: Vector2 = Vector2.ZERO
@onready var line: Line2D = $line
@onready var l: Label = $Label
var changed_times : int = 0

@export_range(1,100,1, "or_greater") var steps : int = 5
@export var t:PackedVector2Array = []
@export var spline_points : PackedVector2Array = []:
	set(val):
		points = val
		while not is_node_ready(): await ready
		asdf(val)
	get:
		asdf(points)
		return points

func asdf(val):
	if val.size() <= 2:
			return
	line.points.resize(val.size() * steps)
	t.resize(val.size() * steps)
	for i in range(val.size()-1):
		for j in range(steps):
			var lepred_v = lerp(val[i], val[i+1], j/steps)
			line.points.set(i*steps + j, lepred_v) 
	queue_redraw()

func _draw():
	if not is_node_ready():
		return
	for p in line.points:
		draw_circle(p, 3, Color(1,1,1,0.75))
	#l.text = str(line.points.size())
	pass
	
func _on_draw():
	pass # Replace with function body.

func _on_item_rect_changed():
	changed_times += 1
	l.text = str(changed_times)
	queue_redraw()
	l.queue_redraw()
	pass # Replace with function body.
