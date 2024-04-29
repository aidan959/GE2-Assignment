class_name Sheep extends CharacterBody3D

@export var mass = 1
@export var force = Vector3.ZERO
@export var acceleration = Vector3.ZERO
@export var vel = Vector3.ZERO
@export var speed:float
@export var max_speed: float = 10.0

@export var behaviours : Array[SteeringBehavior] = [] 
@export var banking = 0.1
@export var damping = 0.1
@export var max_force : float = 10.0


@export var draw_gizmos = true
@export var pause = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var count_neighbors = false
var neighbors = [] 

var flock = null
var new_force = Vector3.ZERO
var should_calculate = false

var grav_vel: Vector3 # Gravity velocity 

# - 0 = not hungry, 1 = hungry
@export_range(0.0,1.0) var hunger : float = 0.0

# - how hungry the sheep gets per frame ? (maybe doing some form of animal_tick later on
@export_range(0.001,1.0) var metabolism : float = 0.001
@export_range(0.0,100.0) var health : float = 100.0

@export_range(0, 60.0) var tick_rate : int = 1 # abstract this to director  

@onready var grazer: Grazer = get_node("Grazer")

var tick_counter :int = 0# abstract this to director 

var hunger_threshold = 0.3
var excessive_eating_chance : int = 1000 # 1/value chance of eating randomly
enum states {
	ROAMING,
	EATING,
	STARING,	# when player is 10-20 m away
	EVADING,		# when player is running 10-20 m away or closer than 10m
	DEAD 			# when it starves to death
} 


func draw_gizmos_propagate(dg):
	draw_gizmos = dg
	var children = get_children()
	for child in children:
		if not child  is SteeringBehavior:
			continue
		child.draw_gizmos = draw_gizmos

var current_state : states
func think():
	# if hungry + on grass + not too near other entities
	if hunger <= 0.0:
		#dead!
		pass
	elif hunger > 0.1 and randi() % excessive_eating_chance == 0:
		# random eating
		change_state(states.EATING)
	elif hunger > 0.7:
		# eat if we arent evading
		change_state(states.EATING)

func _ready():
	randomize()
		# Check for a variable
	if "partition" in get_parent():
		flock = get_parent()
	
	for i in get_child_count():
		var child = get_child(i)
		if not child is SteeringBehavior:
			continue
		behaviours.push_back(child)
		child.draw_gizmos = draw_gizmos
		child.set_process(child.enabled) 
	# enable_all(false)

func _gravity(delta: float) -> Vector3:
	return Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
func _physics_process(delta):
	if pause:
		return
	count_neighbors_simple()
	if max_speed == 0:
		push_warning("max_speed is 0")
	# lerp in the new forces
	if should_calculate:
		new_force = calculate()
		should_calculate = false		
	force = lerp(force, new_force, delta)


	acceleration = force / mass
	velocity += acceleration * delta
	speed = velocity.length()
	if speed > 0:		
		
		velocity = velocity.limit_length(max_speed)
		
		# Damping
		velocity -= velocity * delta * damping
		
		
		move_and_slide()
		
		# Implement Banking as described:
		# https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
		var temp_up = global_transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0)
		look_at(global_transform.origin - velocity.normalized(), temp_up)
	return
	if tick_counter % tick_rate == 0:
		hunger += metabolism * randf_range(0,0.01)
		hunger = clamp(hunger, 0.0, 1.0)
		if (is_equal_approx(hunger, 1.0)):
			health -= 1.0 * randf_range(0.001,0.5)
			
		health = clamp(health, 0, 100.0)
		if(is_equal_approx(health, 0.0)):
			change_state(states.DEAD)
		#print(hunger)
		#print(health)
		
	tick_counter+= 1
	
	match current_state:
		
		states.ROAMING:
			pass#print("roaming about")
		states.EATING:
			pass#print("eating")
		states.DEAD:
			pass#print("DEAD - need to implement mechanism to clean up or decompose bodies")

func change_state(state : states):
	current_state = state

	
func count_neighbors_simple():
	neighbors.clear()
	for i in flock.boids.size():
		var boid = flock.boids[i]
		if boid != self and global_transform.origin.distance_to(boid.global_transform.origin) < flock.neighbor_distance:
			neighbors.push_back(boid)
			if neighbors.size() == flock.max_neighbors:
				break
	return neighbors.size()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_P and event.pressed:
		pause = !pause
		
func set_enabled(behavior, enabled):
	behavior.enabled = enabled
	behavior.set_process(enabled)


func on_draw_gizmos():
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.z * 10.0 , Color(0, 0, 1), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.x * 10.0 , Color(1, 0, 0), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.y * 10.0 , Color(0, 1, 0), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + force, Color(1, 1, 0), 0.1)
	if flock and count_neighbors:
		DebugDraw3D.draw_sphere(global_transform.origin, flock.neighbor_distance, Color.WEB_PURPLE)
		for neighbor in neighbors:
			DebugDraw3D.draw_sphere(neighbor.global_transform.origin, 3, Color.WEB_PURPLE)
			
func seek_force(target: Vector3):	
	var toTarget = target - global_transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * max_speed
	var output = desired - vel
	output.y = 0.0
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
	for behavior in weights:
		var b = get_node(behavior)
		if b: 
			b.weight = weights[behavior]

func calculate():
	var force_acc : Vector3 = Vector3.ZERO
	var behaviors_active = ""
	for i in behaviours.size():
		if not behaviours[i].enabled:
			continue

		var f = behaviours[i].calculate() * behaviours[i].weight

		if is_nan(f.x) or is_nan(f.y) or is_nan(f.z):
			push_error(str(behaviours[i]) + " is NAN")
			f = Vector3.ZERO
		behaviors_active += behaviours[i].name + ": " + str(round(f.length())) + " "
		force_acc += f 
		force_acc.limit_length(max_force)

	if draw_gizmos:
		DebugDraw2D.set_text(name, behaviors_active)

	return force_acc


func _process(delta):
	should_calculate = true
	if draw_gizmos:
		on_draw_gizmos()
		
			
