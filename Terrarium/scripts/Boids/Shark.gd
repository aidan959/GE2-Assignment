class_name Shark extends Boid

var grass = [] 
var is_currently_escaping = false


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

	
func do_be_dead(_delta):
	look_at(global_transform.origin + Vector3(0, -1, 0), Vector3.BACK)



func _physics_process(delta):
	if pause: return
	if is_dead():
		do_be_dead(delta)
		move_and_slide()
		return
	else:
		tick_counter+= 1
		if tick_counter % tick_rate == 0: update_stats()	
	
	count_neighbours_simple(get_script())
	if max_speed == 0:
		push_warning("max_speed is 0")
	#force = Vector3.ZERO # TODO REMOVE
	if should_calculate:
		force = calculate(delta)
		should_calculate = false
	force += process_gravity(delta)
	acceleration = force / mass
	velocity += acceleration * delta


	if is_currently_eating:
		velocity *= delta * 0.1
	else:
		velocity -= velocity * delta * damping
		
	velocity = velocity.limit_length(max_speed)

	move_and_slide()
	if is_zero_approx(velocity.length()) or is_currently_eating:
		global_rotation.x = 0.0
		return
	# Implement Banking as described:
	# https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
	var temp_up = global_transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0)

	look_at(global_transform.origin - velocity.normalized(), temp_up)

func set_enabled(behavior, enabled):
	behavior.enabled = enabled
	behavior.set_process(enabled)

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
	
func update_stats():
	super.update_stats()
