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
@export var max_force : float = 15.0

@onready var ground_detector : Node3D = find_child("GroundDetector")


@export var ground_ray_depth = 100.0
@export var draw_gizmos = true
@export var pause = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var count_neighbors = false

var nearest_grass : Grass = null

var neighbors = [] 
var grass = [] 

var can_graze = false
var is_currently_grazing = false
var is_currently_escaping = false

@onready var sheep_animator : AnimationPlayer = $Sheep/AnimationPlayer
var flock = null
var new_force = Vector3.ZERO
var should_calculate = false

var ascension_light : SpotLight3D = null

var grav_vel: Vector3 # Gravity velocity 

# - 0 = not hungry, 1 = hungry
@export_range(0.0,1.0) var hunger : float = 0.0

# - how hungry the sheep gets per frame ? (maybe doing some form of animal_tick later on
@export_range(0.001,1.0) var metabolism : float = 0.001
@export_range(0.0,100.0) var health : float = 100.0

@export_range(0, 60.0) var tick_rate : int = 1 # abstract this to director  


@export var ui_camera : Camera3D


@export_category("Escape")
@export_range(0.0, 15.0) var escape_distance :float = 10.0

var tick_counter :int = 0# abstract this to director 

var hunger_threshold = 0.3
var excessive_eating_chance : int = 1000 # 1/value chance of eating randomly
enum states {
	ROAMING,
	GRAZING,
	STARING,	# when player is 10-20 m away
	EVADING,		# when player is running 10-20 m away or closer than 10m
	DEAD 			# when it starves to death
} 

enum AnimationStates{
	WALKING,
	STARTING_GRAZING,
	GRAZING
}

var current_animation_state : AnimationStates= AnimationStates.WALKING
func draw_gizmos_propagate(dg):
	draw_gizmos = dg
	var children = get_children()
	for child in children:
		if not child  is SteeringBehavior:
			continue
		child.draw_gizmos = draw_gizmos

var current_state : states


func _ready():
	randomize()
		# Check for a variable
	if not  get_parent() is Flock:
		push_error("Sheep spawned outside of Flock node.")	
	flock = get_parent()
	if flock.grasses.size() == 0: push_warning("No instances of grass found.")	
		
	ascension_light = find_child("AscensionLight")
	for i in get_child_count():
		var child = get_child(i)
		if not child is SteeringBehavior:
			continue
		behaviours.push_back(child)
		child.draw_gizmos = draw_gizmos
		child.set_process(child.enabled) 
	# enable_all(false)
func update_nearest_grass():
	var temp_nearest_distance : float = INF
	var me_pos : Vector3 = global_position
	for grass_entity : Grass in flock.grasses:
		if grass_entity.is_full():
			continue
		var temp_distance = me_pos.distance_to(grass_entity.global_position)
		if temp_distance < temp_nearest_distance:
			temp_nearest_distance = temp_distance
			nearest_grass = grass_entity
	
func _gravity(delta: float) -> Vector3:
	if not is_on_floor():
		grav_vel += Vector3(0, -gravity, 0) * delta
	else:
		grav_vel = Vector3.ZERO
	return grav_vel
func _physics_process(delta):
	if pause:
		return
	if is_dead():
		ascension(delta)
		look_at(global_transform.origin + Vector3(0, -1, 0), Vector3.BACK)
		move_and_slide()
		print("dead")
		return
	else:
		tick_counter+= 1
		if tick_counter % tick_rate == 0: update_stats()	
	
	if hunger > 0.5 and current_state != states.GRAZING:
		change_state(states.GRAZING)
	elif hunger <= 0.1 and current_state == states.GRAZING:
		change_state(states.ROAMING) 
	count_neighbors_simple()
	if max_speed == 0:
		push_warning("max_speed is 0")
	# lerp in the new forces
	if should_calculate:
		force = calculate(delta)
		should_calculate = false
	#force = lerp(force, new_force, delta)

	force += _gravity(delta)
	acceleration = force / mass
	velocity += acceleration * delta


	if is_currently_grazing:
		velocity *= delta * 0.1
	else:
		velocity -= velocity * delta * damping
		
	
	
	
	velocity = velocity.limit_length(max_speed)
	

	move_and_slide()
	if is_zero_approx(velocity.length()) or  is_currently_grazing:
		global_rotation.x = 0.0
		return
	# Implement Banking as described:
	# https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
	var temp_up = global_transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0)

	look_at(global_transform.origin - velocity.normalized(), temp_up)


	
	
func change_state(state : states):
	current_state = state
func is_dead() -> bool:
	return current_state == states.DEAD
	
func count_neighbors_simple():
	neighbors.clear()
	for sheep in flock.boids:
		if sheep != self and !sheep.is_dead() and global_transform.origin.distance_to(sheep.global_transform.origin) < flock.neighbor_distance:
			neighbors.push_back(sheep)
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

func calculate(_delta):
	var force_acc : Vector3 = Vector3.ZERO
	var behaviors_active = ""
	if current_state == states.GRAZING and not is_currently_grazing:
		update_nearest_grass()
	is_currently_escaping = false
	var behaviour_forces = {}
	for behaviour in behaviours:
		if not behaviour.enabled:
			continue
		if current_state == states.GRAZING and (not behaviour is Grazer and not behaviour is Escape):
			continue
		 
		var f = behaviour.calculate().normalized() * behaviour.weight
		if f.length() == 0.0: continue
		if behaviour is Escape: is_currently_escaping = true
		behaviour_forces[behaviour] = f
	if current_state == states.GRAZING and can_graze and not is_currently_escaping:
		is_currently_grazing = true
		return -force/2
		
	is_currently_grazing = false
	for behaviour in behaviour_forces:
		var f = behaviour_forces[behaviour]
		behaviors_active += behaviour.name + ": " + str(round(f.length())) + " "
		force_acc += f

	if draw_gizmos:
		DebugDraw2D.set_text(name, behaviors_active)

	force_acc.limit_length(max_force)
	return force_acc


func _process(_delta):
	should_calculate = true
	if draw_gizmos: on_draw_gizmos()
	update_animation()
	

@export_group("Ascension")
@export var ascension_rate: float = 0.2
@export var ascension_shake_intensity: float = 0.5  
@export var max_ascension_velocity: float = 30.0
var ascension_velocity: Vector3 = Vector3.ZERO

var ascension_acceleration: float = 0.05

func ascension(delta):
	ascension_acceleration += ascension_rate * delta
	ascension_velocity.y += ascension_acceleration * delta
	global_transform.origin += ascension_velocity * delta + get_shake_vector(delta)
	ascension_light.global_transform.origin = global_transform.origin
	ascension_light.global_transform.origin.y += 10.0
	ascension_light.look_at(global_position, Vector3.BACK)
	
func get_shake_vector(delta: float) -> Vector3:
	var shake_vector = Vector3(randf_range(-ascension_shake_intensity, ascension_shake_intensity), 0, randf_range(-ascension_shake_intensity, ascension_shake_intensity))
	return shake_vector * delta

func kill():
	if ascension_light:
		ascension_light.visible = true
	health = 0.0
	current_state = states.DEAD



func update_stats():
	if is_currently_grazing:
		hunger -= metabolism * randf_range(0.5,5.0)
		return
	hunger += metabolism * randf_range(0,0.5)
	hunger = clamp(hunger, 0.0, 1.0)
	if (is_equal_approx(hunger, 1.0)):
		health -= 10.0 * randf_range(0.01,1.0)
	health = clamp(health, 0, 100.0)
	if(is_equal_approx(health, 0.0) and !is_dead()):

		kill()


func change_animation(new_animation: String):
	sheep_animator.play(new_animation, -1, 1.0, true)

func update_animation():
	match current_state:
		states.ROAMING:
			if current_animation_state != AnimationStates.WALKING:
				current_animation_state = AnimationStates.WALKING
				change_animation("Walking_001")
		states.GRAZING:
			if is_currently_grazing == false:
				change_animation("Walking_001")
				current_animation_state = AnimationStates.WALKING
				
			elif current_animation_state == AnimationStates.WALKING:

				current_animation_state = AnimationStates.STARTING_GRAZING
				change_animation("startEat_001")
			elif current_animation_state == AnimationStates.STARTING_GRAZING and sheep_animator.current_animation == "startEat_001" and sheep_animator.is_playing() == false:

				current_animation_state = AnimationStates.GRAZING
				change_animation("Eating_002")  
		states.DEAD:
			sheep_animator.stop()
