extends Node3D

var speed = 10
var wave_amplitude = 0.5
var wave_frequency = 1
var neck_scene = preload("res://scenes/Neck.tscn")
var target_sheep = null
var start_position = null
var neck_parts = []
var movement_path = []
var boid_controller_path = "../../../../BoidController"
@export var boid_controller: BoidController
var total_time = 0.0  # Time accumulator to calculate sin wave phase

func _ready():
	start_position = global_transform.origin

func _process(delta):
	total_time += delta
	var path3d = get_node_or_null("../../../")
	if path3d:
		if target_sheep:
			path3d.call("set_movement_allowed", false)
			move_towards_target(delta)
		else:
			path3d.call("set_movement_allowed", true)
	else:
		print("Path3D node not found")

	if target_sheep == null:
		target_sheep = get_random_sheep_child()

func get_random_sheep_child():
	var boid_controller = get_node_or_null(boid_controller_path)
	if boid_controller:
		var sheep_boids = boid_controller.boids[typeof(Sheep)]
		if sheep_boids.size() > 0:
			var random_index = randi() % sheep_boids.size()
			return sheep_boids[random_index]
		else:
			print(boid_controller.boids[typeof(Sheep)])
	else:
		print("BoidController not found")
	return null


var moving_back = false

func move_towards_target(delta):
	if target_sheep and not moving_back:
		var direction = (target_sheep.global_transform.origin - global_transform.origin).normalized()
		var new_position = global_transform.origin + direction * speed * delta
		var lateral_offset = get_perpendicular_vector(direction) * sin(total_time * wave_frequency) * wave_amplitude
		global_transform.origin = new_position + lateral_offset
		movement_path.append(global_transform.origin)
		create_neck_at_position()
		if global_transform.origin.distance_to(target_sheep.global_transform.origin) < 8.0:
			moving_back = true
	elif moving_back:
		if movement_path.size() > 0:
			global_transform.origin = movement_path.pop_back()
			delete_neck_as_moving_back()
		else:
			moving_back = false

func get_perpendicular_vector(direction):
	var up_vector = Vector3.UP
	return direction.cross(up_vector).normalized()

func create_neck_at_position():
	var neck_instance = neck_scene.instantiate()
	neck_instance.global_transform = global_transform
	var main_scene_root = get_tree().root.get_node("Main")
	main_scene_root.add_child(neck_instance)
	neck_parts.append(neck_instance)

func delete_neck_as_moving_back():
	if neck_parts.size() > 0:
		var last_neck_part = neck_parts.pop_back()
		last_neck_part.queue_free()
