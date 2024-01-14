extends RigidBody2D
var mouse_in: bool = true
var picked: bool = false




func _on_mouse_entered():
	mouse_in = true


func _on_mouse_exited():
	mouse_in = false

func _physics_process(delta):
	if picked and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position += get_local_mouse_position()


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: 
			if event.pressed:
				freeze = true
				picked = true
			else:
				freeze = false
				picked = false
			
	
