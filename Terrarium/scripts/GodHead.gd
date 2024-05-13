class_name GodHead extends PathFollow3D

var speed = 20
var wave_amplitude = 0.5
var wave_frequency = 1
var target_sheep = null
var start_position = null
var neck_parts = []
var movement_path = []
var movement_transforms = [] 
@export_range(0.0, 50.0) var path_speed : float = 10.0
@export var neck_scene : PackedScene = preload("res://scenes/Neck.tscn")
@export var pick_sheep : bool = false
@export var boid_controller: BoidController
@export var path_3d : Path3D
var total_time = 0.0 

func _ready():
	start_position = global_transform.origin
	if not boid_controller:	
		boid_controller = get_node_or_null("../../BoidController")
	if not boid_controller:
		push_error("GodCloud cannot find BoidController")
	if not path_3d:
		var parent =  get_parent()
		if parent is Path3D:
			path_3d = parent
		else:
			push_error("GodCloud should have Path3D field, or be child of Path3D")
func _process(delta):
	total_time += delta
	if path_3d:
		if target_sheep:
			move_towards_target(delta)
		else:
			progress += path_speed * delta

	if boid_controller:
		if not Sheep.get_boid_type() in boid_controller.boids: 
			return
		var sheep_boids = boid_controller.boids[Sheep.get_boid_type()]
		if sheep_boids.size() > 110:
			pick_sheep = true
	if pick_sheep == true:
		if target_sheep == null:
			target_sheep = get_random_sheep_child()

func get_random_sheep_child() -> Sheep:
	if boid_controller:
		var sheep_boids = boid_controller.boids[Sheep.get_boid_type()]
		if sheep_boids.size() > 0:
			return sheep_boids.pick_random()
	return null


var moving_back = false

func move_towards_target(delta):
	if target_sheep and not moving_back:
		var direction = (target_sheep.global_transform.origin - global_transform.origin).normalized()
		var next_time = total_time + delta
		var future_lateral_offset = get_perpendicular_vector(direction) * sin(next_time * wave_frequency) * wave_amplitude
		var future_position = global_transform.origin + direction * speed * delta + future_lateral_offset
		align_head(future_position)
		var lateral_offset = get_perpendicular_vector(direction) * sin(total_time * wave_frequency) * wave_amplitude
		global_transform.origin += direction * speed * delta + lateral_offset
		movement_transforms.append(global_transform)
		create_neck_at_position()
		var distance_to_sheep = global_transform.origin.distance_to(target_sheep.global_transform.origin)
		if distance_to_sheep < 30.0:
			speed = lerp(20.0, 5.0, remap(distance_to_sheep, 7.0, 30.0, 1.0, 0.0))
		if distance_to_sheep < 3.0:
			moving_back = true
	elif moving_back:
		if movement_transforms.size() > 0:
			global_transform = movement_transforms.pop_back()
			delete_neck_as_moving_back()
		else:
			speed = 20
			moving_back = false
			pick_sheep =false

func get_perpendicular_vector(direction):
	var up_vector = Vector3.UP
	return direction.cross(up_vector).normalized()

func align_head(future_position):
	global_transform = global_transform.looking_at(future_position, Vector3.UP)
	global_transform.basis = global_transform.basis.rotated(Vector3.UP, PI / 2)

func create_neck_at_position():
	if movement_transforms.size() <= 1:
		return

	var neck_instance = neck_scene.instantiate()
	var last_transform = movement_transforms[movement_transforms.size() - 2]
	var offset_distance = 2.0 
	var backward_direction = (movement_transforms[movement_transforms.size() - 2].origin - movement_transforms[movement_transforms.size() - 1].origin).normalized()
	var offset_position = last_transform.origin + backward_direction * offset_distance
	neck_instance.global_transform = Transform3D(last_transform.basis, offset_position)
	var main_scene_root = get_tree().root.get_node("Main")
	main_scene_root.add_child(neck_instance)
	neck_parts.append(neck_instance)

func delete_neck_as_moving_back():
	if neck_parts.is_empty():
		return
		
	var last_neck_part = neck_parts.pop_back()
	last_neck_part.queue_free()
