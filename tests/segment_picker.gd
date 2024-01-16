class_name SegmentPicker
extends Control


enum{MODE_IDLE, MODE_DRAG}
var mode = MODE_IDLE
var index = 0

signal point_moved(idx: int, pos: Vector2)
func set_index(idx: int):
	index = idx
	
func _ready():
	pass
	
func get_nearest_segment():
	pass

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mode = MODE_DRAG
		if event.button_index == MOUSE_BUTTON_LEFT and (not event.pressed):
			mode = MODE_IDLE


func _input(event):
	if event is InputEventMouseMotion and mode == MODE_DRAG:
		my_set_position(get_global_mouse_position())
		
func my_set_position(new_position: Vector2):
	position = new_position - Vector2(4, 4)
	point_moved.emit(index, new_position)
	
	
