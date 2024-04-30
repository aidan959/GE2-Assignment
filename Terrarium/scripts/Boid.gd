class_name Boid extends CharacterBody3D
@export_category("Steering")
@export var mass = 1
@export var force = Vector3.ZERO
@export var acceleration = Vector3.ZERO
@export var vel = Vector3.ZERO
@export var speed:float
@export var max_speed: float = 10.0
@export var max_force = 10
@export var banking = 0.1
@export var damping = 0.1
@export_range(0.0,50.0) var neighbor_distance = 10.0

@export var behaviours : Array[SteeringBehavior] = [] 

@export_category("Debug")
@export var draw_gizmos = true
@export var pause = false

@export_category("Vitals")
@export_range(0.0,100.0) var health : float = 100.0
@export_range(0.0,1.0) var hunger : float = 0.0
@export_range(0.001,1.0) var metabolism : float = 0.001
@export_range(0, 60.0) var tick_rate : int = 1 # abstract this to director  
@export var is_currently_eating = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var grav_vel: Vector3
@export var current_state : BoidStates

enum BoidStates {
	ROAMING,
	GRAZING,
	DEAD
} 
var flock : BoidController = null

var tick_counter :int = 0 
var count_neighbours = false
var neighbours = [] 
var new_force = Vector3.ZERO
var should_calculate = false
func initialize_flock():
	if not get_parent() is BoidController:
		push_error("Boid spawned outside of BoidManager node.")	
	flock = get_parent()
	if flock.grasses.size() == 0: push_warning("No instances of grass found.")

func initialize_behaviours():
	for i in get_child_count():
		var child = get_child(i)
		if not child is SteeringBehavior:
			continue
		behaviours.push_back(child)
		child.draw_gizmos = draw_gizmos
		child.set_process(child.enabled)
 
func _ready():
	randomize()
	initialize_flock()
	initialize_behaviours()

func draw_gizmos_propagate(dg):
	draw_gizmos = dg
	var children = get_children()
	for child in children:
		if not child is SteeringBehavior: continue
		child.draw_gizmos = draw_gizmos

func process_gravity(delta: float) -> Vector3:
	if not is_on_floor():
		grav_vel += Vector3(0, -gravity, 0) * delta
	else:
		grav_vel = Vector3.ZERO
	return grav_vel


func count_neighbours_simple(type: Variant):
	neighbours.clear()
	if type not in flock.boids:
		return 0
	for boid in flock.boids[type]:
		if boid != self and !boid.is_dead() and global_position.distance_to(global_position) < flock.neighbor_distance:
			neighbours.push_back(boid)
			if neighbours.size() == flock.max_neighbours:
				break
	return neighbours.size()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_P and event.pressed:
		pause = ! pause
		
func set_enabled(behaviour, enabled):
	behaviour.enabled = enabled
	behaviour.set_process(enabled)


func on_draw_gizmos():
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.z * 10.0 , Color(0, 0, 1), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.x * 10.0 , Color(1, 0, 0), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.y * 10.0 , Color(0, 1, 0), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + force, Color(1, 1, 0), 0.1)
	if flock and count_neighbours:
		DebugDraw3D.draw_sphere(global_transform.origin, flock.neighbor_distance, Color.WEB_PURPLE)
		for neighbour in neighbours:
			DebugDraw3D.draw_sphere(neighbour.global_transform.origin, 3, Color.WEB_PURPLE)
		
func seek_force(target: Vector3):	
	var toTarget = target - global_transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * max_speed
	var output = desired - vel
	output.y = 0.0 # todo why?
	return output
	
func arrive_force(target:Vector3, slowingDistance:float):
	var toTarget = target - global_transform.origin
	var dist = toTarget.length()
	
	if dist < 2:
		return Vector3.ZERO
	
	var ramped = (dist / slowingDistance) * max_speed
	var limit_length = min(max_speed, ramped)
	var desired = (toTarget * limit_length) / dist 
	return desired - vel


	
func set_enabled_all(enabled):
	for i in behaviours.size():
		behaviours[i].enabled = enabled
		
func update_weights(weights):
	for behaviour in weights:
		var b = get_node(behaviour)
		if b: 
			b.weight = weights[behaviour]

func calculate(_delta):
	var force_acc = Vector3.ZERO	
	var behaviours_active = ""
	for i in behaviours.size():
		if behaviours[i].enabled:
			var f = behaviours[i].calculate() * behaviours[i].weight
			if is_nan(f.x) or is_nan(f.y) or is_nan(f.z):
				print(str(behaviours[i]) + " is NAN")
				f = Vector3.ZERO
			behaviours_active += behaviours[i].name + ": " + str(round(f.length())) + " "
			force_acc += f 
	force_acc = force_acc.limit_length(max_force)
	if draw_gizmos:
		DebugDraw2D.set_text(name, behaviours_active)
	return force_acc


func _process(_delta):
	should_calculate = true
	if draw_gizmos: on_draw_gizmos()


func kill():
	health = 0.0
	current_state = BoidStates.DEAD

func is_dead() -> bool:
	return current_state == BoidStates.DEAD

func change_state(state : BoidStates):
	current_state = state

func update_stats():
	if is_currently_eating:
		hunger -= metabolism * randf_range(0.5,5.0)
		return
	hunger += metabolism * randf_range(0,0.5)
	hunger = clamp(hunger, 0.0, 1.0)
	if (is_equal_approx(hunger, 1.0)):
		health -= 10.0 * randf_range(0.01,1.0)
	health = clamp(health, 0, 100.0)
	if(is_equal_approx(health, 0.0) and !is_dead()):
		kill()
	
func do_be_dead(_delta):
	pass
	
func _physics_process(delta):
	# pause = true
	# lerp in the new forces
	if should_calculate:
		new_force = calculate(delta)
		should_calculate = false		
	force = lerp(force, new_force, delta)
	if ! pause:
		acceleration = force / mass
		vel += acceleration * delta
		speed = vel.length()
		if speed > 0:
			if max_speed == 0:
				print("max_speed is 0")
			vel = vel.limit_length(max_speed)
			
			# Damping
			vel -= vel * delta * damping
			
			set_velocity(vel)
			move_and_slide()
			
			# Implement Banking as described:
			# https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
			var temp_up = global_transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0)
			look_at(global_transform.origin - vel.normalized(), temp_up)
