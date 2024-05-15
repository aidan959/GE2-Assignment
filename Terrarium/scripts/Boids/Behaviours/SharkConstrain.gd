class_name SharkConstrain extends SteeringBehavior

@export var water_top : float
@export var water_bottom : float
@export var radius:float = 100

var center
func on_draw_gizmos():
	pass
	#var center_pos = center.global_transform.origin if center else Vector3.ZERO 
	#DebugDraw3D.draw_sphere(center_pos, radius, Color.BEIGE)


func calculate():
	if boid.environment_controller.rain_particles.emitting:
		var to_center = center.global_transform.origin - boid.global_transform.origin if center else - boid.global_transform.origin 
#	
		var power = max(to_center.length() - radius, 0)
		force = to_center.limit_length(power)
		pass
	else:
		pass # return to normal height
#	Inline IF!! 
	if boid.global_position.y > water_top:
		force = Vector3(0, -1, 0)
	elif boid.global_position.y < water_bottom:
		force = Vector3(0, 1, 0)
	else:
		force = Vector3.ZERO
	return force
	
# Called when the node enters the scene tree for the first time.
func _ready():
	boid = get_parent()
	# boid.transform.rotated()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
