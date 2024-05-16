class_name GodHead extends PathFollow3D

var speed = 20
var wave_amplitude = 0.5
var wave_frequency = 1
var target_sheep = null
var start_position = null
var birth_sheep = null
var target = null
var moving_back = false
var neck_parts = []
var movement_path = []
var movement_transforms = [] 
var birth_spot = Vector3(-40,25,-15)
var amount_of_sheep_to_spawn : int 
var sheep_boids = []

@export_range(0, 200) var minimum_amount_of_sheep : int
@export_range(0, 200) var maximum_amount_of_sheep : int
@export_range(0.1, 1.0) var max_spawner_time
@export_range(0.1, 1.0) var min_spawner_time
@export_range(0.0, 50.0) var path_speed : float = 10.0

@export var neck_scene : PackedScene = preload("res://scenes/Neck.tscn")
@export var pick_sheep : bool = false
@export var boid_controller: BoidController
@export var path_3d : Path3D
@onready var birthtimer : Timer = $BirthTimer
@onready var godhead : Node3D = $GodHead
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
	if not godhead:
		var child = find_child("GodHead")
		if child is Node3D:
			godhead = child
		else:
			push_error("Godcloud could not find child - GodHead")
		
	if not birthtimer:
		var child = find_child("BirthTimer")
		if child is Timer:
			birthtimer = child
			birthtimer.start()
		else:
			push_error("Godcloud could not find child - BirthTimer")
	
func _process(delta):
	total_time += delta
	if path_3d:
		if target_sheep: # added to stop this code from running
			target = target_sheep.global_transform.origin
			move_towards_target(target, delta)
		elif birth_sheep:
			target = birth_spot
			move_towards_target(target, delta)
		else:
			progress += path_speed * delta

	if boid_controller:
		if not Sheep.get_boid_type() in boid_controller.boids: 
			return
		
		sheep_boids = boid_controller.boids[Sheep.get_boid_type()]
		minimum_amount_of_sheep = int(boid_controller.spawn_amount[Sheep.get_boid_type()] * 0.8)
		maximum_amount_of_sheep = minimum_amount_of_sheep * 1.3
		if sheep_boids.size() == maximum_amount_of_sheep:
			pick_sheep = true
		if sheep_boids.size() < minimum_amount_of_sheep:
			birth_sheep = true
	if pick_sheep == true:
		if target_sheep == null:
			target_sheep = get_random_sheep_child()
			

func get_random_sheep_child() -> Sheep:
	if boid_controller:
		var sheep_boids = boid_controller.boids[Sheep.get_boid_type()]
		if sheep_boids.size() > 0:
			return sheep_boids.pick_random()
	return null

func move_towards_target(target, delta):
	if target and not moving_back:
		var direction = (target - godhead.global_transform.origin).normalized()
		var next_time = total_time + delta
		var future_lateral_offset = get_perpendicular_vector(direction) * sin(next_time * wave_frequency) * wave_amplitude
		var future_position = godhead.global_transform.origin + direction * speed * delta + future_lateral_offset
		align_head(future_position)
		var lateral_offset = get_perpendicular_vector(direction) * sin(total_time * wave_frequency) * wave_amplitude
		godhead.global_transform.origin += direction * speed * delta + lateral_offset
		movement_transforms.append(godhead.global_transform)
		create_neck_at_position()
		var distance_to_target = godhead.global_transform.origin.distance_to(target)
		if distance_to_target < 30.0:
			speed = lerp(20.0, 1.0, remap(distance_to_target, 5.0, 30.0, 1.0, 0.0))
		if distance_to_target < 3.0:
			if birth_sheep:
				amount_of_sheep_to_spawn = maximum_amount_of_sheep - sheep_boids.size()
				if amount_of_sheep_to_spawn == 0:
					moving_back = true
			else:
				target_sheep.scale = Vector3(2,2,2)
				
				moving_back = true
	elif moving_back:
		if movement_transforms.size() > 0:
			godhead.global_transform = movement_transforms.pop_back()
			delete_neck_as_moving_back()
		else:
			speed = 20
			moving_back = false
			pick_sheep = false
			target_sheep = null

func get_perpendicular_vector(direction):
	var up_vector = Vector3.UP
	return direction.cross(up_vector).normalized()

func align_head(future_position):
	godhead.global_transform = godhead.global_transform.looking_at(future_position, Vector3.UP)
	godhead.global_transform.basis = godhead.global_transform.basis.rotated(Vector3.UP, PI / 2)

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

func _on_sheep_detector_body_entered(body):
	if body is Sheep and body.is_dead():
		body.explode()

func _on_birth_timer_timeout():
	if amount_of_sheep_to_spawn > 0:
		boid_controller.spawn_boid("Sheep", godhead.global_transform.origin)
		amount_of_sheep_to_spawn =- 1

