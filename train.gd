class_name Train
extends RigidBody2D
#train calculates it own way into Path and move all carriges along it with them PathFollow
#path updates with new segment from real lines

@export var curve : Curve2D = null:
	set(val):
		curve = val
		path.curve = curve

@onready var path : Path2D = $Path
@onready var cars : Node = $Cars
var lead_loco: Car #loco with what we play train
var train_mass: float = 0.0
var train_force: float = 0.0

var direction: int = 1  #-1 backward, 0 -neutral, 1 = forward 
var rudder_pos: float = 0.0
var brak_pos: float = 0.0

var watch_car_in_collision: RigidBody2D = null
@onready var rudder_tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: except cars for cars in train conllision
	Railways.railwais_ready.connect(_on_railwais_ready)

	for car in get_children():
		if car is RigidBody2D:
			train_mass += car.mass
			#TODO: set total_mass for every of carrige
			if car.loco:
				train_force += car.engine_force
				lead_loco = car #TODO: select lead loco by level of loco
			car.velocity_changed.connect(_on_car_collision_velocity_changed)
	for car in get_children():
		if car is RigidBody2D:
			car.set_train_mass(train_mass)
			#TODO: reset train mass due disconect car from train
	
func _on_railwais_ready():
	#collect curves segvents and make own way
	#var train_pts : RailwayNearestPart = null
	#for car in get_children():
		#if car is Car:
			#if train_pts == null:
				#train_pts = Railways.get_nearest_points(car.position)
			#else:
				#if not train_pts.append_part(Railways.get_nearest_points(car.position)):
					##car.flip = not car.flip
					#pass
				
			#var car_pts : Dictionary = 
			#if car_pts.is_empty():
				#print("Eroor: NO RAIL FOR car ", car)
				#return
			##check path alreadi in dict
			#var car_path = car_pts.keys()[0]
			#if car_path in train_pts:
				##recalculate min and max points
				#if car_pts[car_path]["pre"] < train_pts[car_path]["pre"]:
					#train_pts[car_path]["pre"] = car_pts[car_path]["pre"]
				#if car_pts[car_path]["post"] > train_pts[car_path]["post"]:
					#train_pts[car_path]["post"] = car_pts[car_path]["post"]
				#train_pts[car_path]["cars"].append(car) #add car in list for Path
			#else: #new Path
				#car_pts[car_path]["cars"] = [car]
				#train_pts.merge(car_pts)
				
	#generate curve for path
	#var net_paths : Array[Path2D] = train_pts.keys()
	##use first path as base for trains path
	#for i in range(train_pts[net_paths[0]]["pre"], train_pts[net_paths[0]]["post"] + 1):
		##Path2D
		#path.curve.add_point(
			#net_paths[0].get_point_position(i), 
			#net_paths[0].get_point_in(i),
			#net_paths[0].get_point_out(i)
			#)
	#net_paths.remove_at(0)
	##find connected to main curve branches
	#while net_paths.size() > 0:
		##is_connected_to_start(net_paths[0], train_pts[net_paths[0]]["pre"])
		#pass
	
	print("OK")
	
func set_force(level: float):
	rudder_pos = level
	
func update_path(pos: Vector2, in_: Vector2, out_: Vector2):
	path.curve.add_point(pos, in_, out_)

func attach_car(car : RigidBody2D):
	cars.add_child(car)
	pass

func set_lead_loco(car: RigidBody2D):
	lead_loco = car
	pass

func _integrate_forces(state):
	for child in get_children():
		if child is RigidBody2D:
			#print("TRAIN:", name, child.linear_velocity)
			pass
	#TODO: Calculate final velocity vector length
	#F/m *dt
	pass
	
#self owned path which along moves train
func calculate_path(node: RigidBody2D):
	#rails_api.curve.get_baked_length()
	#print(node.name, "point ", path.curve.get_closest_point(node.position), " ", node.position)
	#get_nearest_point
	
	#TODO: get node move vector
	pass
	
func _physics_process(delta):
	if Input.is_key_pressed(KEY_W) and lead_loco:
		var total_force : float = 0.0
		for child in get_children():
			if child is Car and child.loco:
				total_force += child.get_engine_force(1.0) #TODO: every engine
		var force_on_one_mass = total_force / train_mass * lead_loco.get_main_loco_dir()
		for child in get_children():
			if child is Car:
				child.set_train_force_part(child.mass * force_on_one_mass)
				
		#set_throttle(1.0)
	else:
		for child in get_children():
			if child is Car:
				child.set_train_force_part(0.0)
		#set_throttle(0.0)
 			
	var all_sleep = true
	for child in get_children():
		if child is RigidBody2D:
			if child.sleeping == true:
				calculate_path(child)
				all_sleep = false
				break
			#print("TRAIN---:", name, child.linear_velocity)
	#clear path if every body is sleeping
	
func _on_car_collision_velocity_changed(car: RigidBody2D, vel: Vector2):
	#NOTE: after collision the car velicity is changed instead of rest of carriges in train
	watch_car_in_collision = car
	
	#TODO: recalculate cars position
	#TODO: setup cars velocity vectors
	pass
	
func _on_car_velocity_stabilized(car: RigidBody2D, vel: Vector2):
	watch_car_in_collision = null
	
func set_direction(dir: int):
	if not lead_loco:
		return
	lead_loco.direction = dir

func set_throttle(throttle_level):
	if not lead_loco:
		return
	#if rudder_tween :
		#rudder_tween.free()
	#rudder_tween = get_tree().create_tween()
	#rudder_tween.tween_property(lead_loco, "throttle_level", thrust_lvl, 1.0)
	lead_loco.throttle_level = throttle_level

##set path along what train and it cars can move
#func set_path(path: Path2D) -> void:
	#self.path = path
	#for child in get_children():
		#if child is Car:
			##setup new path for Car follow
			#child.path = path #temp
			#var child_follow : PathFollow2D = child.get_follow()
			#if child_follow.get_parent() == null:
				#path.add_child(child_follow)
			#else:
				#child_follow.reparent(path)
			##move follow
			#child_follow.progress = path.curve.get_closest_offset(child.position)

func flip_curve():
	var old_curve : Curve2D = $Path.curve
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
	$Path.curve = new_curve
	
	for child in get_children():
		if child is Car:
			child.flip = not child.flip
