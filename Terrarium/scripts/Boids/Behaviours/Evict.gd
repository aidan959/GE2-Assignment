class_name Evict extends SteeringBehavior

@export var radius:float = 100

@export var center_path:NodePath

var center

func on_draw_gizmos():
	var center_pos = center.global_transform.origin if center else Vector3.ZERO 
	DebugDraw3D.draw_sphere(center_pos, radius, Color.BEIGE)

@onready var start_weight : float = weight
func calculate():
	if boid.environment_controller.rain_particles.emitting:
		weight = 0.0
	else:
		weight = start_weight
	var to_center = -(center.global_transform.origin - boid.global_transform.origin if center else - boid.global_transform.origin )
#	
	var power = max(to_center.length() - radius, 0)
	force = to_center.limit_length(power)
	return force
	
# Called when the node enters the scene tree for the first time.
func _ready():
	boid = get_parent()
	if center_path:
		center = get_node(center_path)
	# boid.transform.rotated()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
