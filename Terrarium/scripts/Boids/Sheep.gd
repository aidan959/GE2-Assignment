class_name Sheep extends Boid

var nearest_grass : GrassFood = null
var grass = [] 
var is_currently_escaping = false

@onready var animator : AnimationPlayer = $Sheep/AnimationPlayer
@onready var ExplosionParticles = load("res://scenes/explosion_particles.tscn")


var ascension_light : SpotLight3D = null

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
	foods_liked = [Grass]
	ascension_light = find_child("AscensionLight")

func update_nearest_grass():
	var temp_nearest_distance : float = INF
	var me_pos : Vector3 = global_position
	for grass_entity : GrassFood in flock.grasses:
		if grass_entity.is_full() or grass_entity.fullness == 0:
			nearest_grass = null
			continue
		var temp_distance = me_pos.distance_to(grass_entity.global_position)
		if temp_distance < temp_nearest_distance:
			temp_nearest_distance = temp_distance
			nearest_grass = grass_entity

	
func do_be_dead(delta):
	ascension(delta)
	move_and_slide()
	# look_at(global_transform.origin + Vector3(0, -1, 0), Vector3.BACK)

func _physics_process(delta):
	if pause: return
	tick_counter+= 1
	if tick_counter % tick_rate == 0: update_stats()	
	if is_dead():
		do_be_dead(delta)
		return
		
	if nearest_grass == null:
		#print("no nearest_grass")
		pass
		
	if hunger <= 0.1 or nearest_grass == null:
		change_state(BoidStates.ROAMING)

	elif hunger > 0.5 and current_state != BoidStates.GRAZING:
		change_state(BoidStates.GRAZING)
		
	count_neighbours_simple(Sheep)
	
	if max_speed == 0:
		push_warning("max_speed is 0")
	# lerp in the new forces
	if should_calculate:
		force = calculate(delta)
		should_calculate = false
	#force = lerp(force, new_force, delta)
	
	if is_in_water:
		force.y += 0.5
		
	else:
		force += super.process_gravity(delta)
	
	acceleration = force / mass
	velocity += acceleration * delta


		
		
	if is_currently_eating:
		velocity *= delta * 0.1
	else:
		
		velocity -= velocity * delta * damping

	velocity = velocity.limit_length(max_speed)
	
	move_and_slide()
	if is_zero_approx(velocity.length()) or  is_currently_eating:
		global_rotation.x = 0.0
		return
	# Implement Banking as described:
	# https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/

	var temp_up = global_transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0)

	var target : Vector3 = global_transform.origin - velocity.normalized()
	var target_dot : float = temp_up.dot(target)
	
	if not is_equal_approx(target_dot, 1.0):
	
		look_at(global_transform.origin - velocity.normalized(), temp_up)
		

func set_enabled(behavior, enabled):
	behavior.enabled = enabled
	behavior.set_process(enabled)


func on_draw_gizmos():
	super()
			
func arrive_force(target:Vector3, slowingDistance:float):
	var toTarget = target - global_transform.origin
	var dist = toTarget.length()
	
	if dist < 2:
		return Vector3.ZERO
	
	var ramped = (dist / slowingDistance) * max_speed
	var limit_length = min(max_speed, ramped)
	var desired = (toTarget * limit_length) / dist 
	return desired - velocity

	
func set_enabled_all(enabled):
	for i in behaviours.size():
		behaviours[i].enabled = enabled
		
func update_weights(weights):
	for behavior in weights:
		var b = get_node(behavior)
		if b: 
			b.weight = weights[behavior]
var behavior_sound_weights = {}
func calculate(_delta):
	behavior_sound_weights = {}
	var force_acc : Vector3 = Vector3.ZERO
	var behaviors_active = ""
	if not is_currently_eating:
		update_nearest_grass()
	is_currently_escaping = false
	var behaviour_forces = {}
	reset_debug_influencing_weight()
	for behaviour in behaviours:
		if not behaviour.enabled:
			continue
		if current_state == BoidStates.GRAZING and (not behaviour is Grazer and not behaviour is Escape):
			continue
			
		var f = behaviour.calculate() * behaviour.weight
		if f.length() == 0.0: continue
		if behaviour is Escape: is_currently_escaping = true
		behaviour_forces[behaviour] = f
		add_debug_influencing_weight(behaviour, f)
	if current_state == BoidStates.GRAZING and can_eat and not is_currently_escaping:
		is_currently_eating = true
		return -force/2
		
	is_currently_eating = false
	for behaviour in behaviour_forces:
		var f = behaviour_forces[behaviour]
		force_acc += f
		# Calculate sound weight for the behavior
		var sound_weight = f.length() * behaviour.sound_weight
		behavior_sound_weights[behaviour] = sound_weight

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
@export var explosion_threshold: float = 5.0  # Distance within which explosion triggers
var ascension_velocity: Vector3 = Vector3.ZERO
var ascension_acceleration: float = 0.05
var exploded = false  # To ensure the explosion only happens once

func ascension(delta):
	if exploded:
		return
	
	var godsheep = get_node("../../Path3D/PathFollow3D")
	var target_position = godsheep.global_transform.origin
	DebugDraw3D.draw_box(target_position, Quaternion(), Vector3(10, 10, 10), Color.BLUE)
	var direction_to_target = (target_position - global_transform.origin).normalized()
	
	ascension_acceleration += ascension_rate * delta
	ascension_velocity += direction_to_target * ascension_acceleration * delta
	ascension_velocity = ascension_velocity.normalized() * min(ascension_velocity.length(), max_ascension_velocity) + get_shake_vector(delta)
	
	global_transform.origin += ascension_velocity * delta
	ascension_light.global_transform.origin = global_transform.origin + Vector3(0, 10.0, 0)
	if not is_equal_approx(ascension_light.global_position.dot(global_position), 1.0):
		ascension_light.look_at(global_position, Vector3.UP)
	if ascension_velocity.length() > 0:
		look_at(global_transform.origin + ascension_velocity.normalized(), Vector3.DOWN)
	else:
		look_at(global_transform.origin + Vector3(0, 0, 1), Vector3.DOWN)
	
	if global_transform.origin.distance_to(target_position) < explosion_threshold:
		explode()

func explode():
	var particles = ExplosionParticles.instantiate()
	add_child(particles)
	print("boom")
	particles.transform.origin = transform.origin
	# exploded = true
	# queue_free()


func get_shake_vector(delta: float) -> Vector3:
	var shake_vector = Vector3(randf_range(-ascension_shake_intensity, ascension_shake_intensity), 0, randf_range(-ascension_shake_intensity, ascension_shake_intensity))
	return shake_vector * delta

func kill():
	super.kill()
	if ascension_light:
		ascension_light.visible = true

func update_stats():
	super.update_stats()

func change_animation(new_animation: String):
	animator.play(new_animation, -1, 1.0, true)

func update_animation():
	match current_state:
		BoidStates.ROAMING:
			if current_animation_state != AnimationStates.WALKING:
				current_animation_state = AnimationStates.WALKING
				change_animation("Walking_001")
		BoidStates.GRAZING:
			if is_currently_eating == false:
				change_animation("Walking_001")
				current_animation_state = AnimationStates.WALKING
				
			elif current_animation_state == AnimationStates.WALKING:

				current_animation_state = AnimationStates.STARTING_GRAZING
				change_animation("startEat_001")
			elif current_animation_state == AnimationStates.STARTING_GRAZING and animator.current_animation == "startEat_001" and animator.is_playing() == false:

				current_animation_state = AnimationStates.GRAZING
				change_animation("Eating_002")  
		BoidStates.DEAD:
			animator.stop()
