class_name Sheep extends Boid



var nearest_grass : Grass = null
 
var grass = [] 

var can_graze = false
var is_currently_grazing = false
var is_currently_escaping = false

@onready var animator : AnimationPlayer = $Sheep/AnimationPlayer


var ascension_light : SpotLight3D = null

var grav_vel: Vector3

@export_category("Escape")
@export_range(0.0, 15.0) var escape_distance :float = 10.0


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
		if not child is SteeringBehavior: continue
		child.draw_gizmos = draw_gizmos


func _ready():
	super._ready()
	ascension_light = find_child("AscensionLight")

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
	
	if hunger > 0.5 and current_state != BoidStates.GRAZING:
		change_state(BoidStates.GRAZING)
	elif hunger <= 0.1 and current_state == BoidStates.GRAZING:
		change_state(BoidStates.ROAMING) 
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


	
	
func change_state(state : BoidStates):
	current_state = state
func is_dead() -> bool:
	return current_state == BoidStates.DEAD

	

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
	if current_state == BoidStates.GRAZING and not is_currently_grazing:
		update_nearest_grass()
	is_currently_escaping = false
	var behaviour_forces = {}
	for behaviour in behaviours:
		if not behaviour.enabled:
			continue
		if current_state == BoidStates.GRAZING and (not behaviour is Grazer and not behaviour is Escape):
			continue
		 
		var f = behaviour.calculate().normalized() * behaviour.weight
		if f.length() == 0.0: continue
		if behaviour is Escape: is_currently_escaping = true
		behaviour_forces[behaviour] = f
	if current_state == BoidStates.GRAZING and can_graze and not is_currently_escaping:
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
	current_state = BoidStates.DEAD



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
		BoidStates.ROAMING:
			if current_animation_state != AnimationStates.WALKING:
				current_animation_state = AnimationStates.WALKING
				change_animation("Walking_001")
		BoidStates.GRAZING:
			if is_currently_grazing == false:
				change_animation("Walking_001")
				current_animation_state = AnimationStates.WALKING
				
			elif current_animation_state == AnimationStates.WALKING:

				current_animation_state = AnimationStates.STARTING_GRAZING
				change_animation("startEat_001")
			elif current_animation_state == AnimationStates.STARTING_GRAZING and sheep_animator.current_animation == "startEat_001" and sheep_animator.is_playing() == false:

				current_animation_state = AnimationStates.GRAZING
				change_animation("Eating_002")  
		BoidStates.DEAD:
			sheep_animator.stop()
