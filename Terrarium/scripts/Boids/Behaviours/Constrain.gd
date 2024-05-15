class_name Constrain extends SteeringBehavior

@export var radius:float = 100

@export var center_path:NodePath

var center

func on_draw_gizmos():
	var center_pos = center.global_postition if center else Vector3.ZERO 
	DebugDraw3D.draw_sphere(center_pos, radius, Color.BEIGE)


func calculate():
#	Inline IF!! 
	var to_center = center.global_position - boid.global_transform.origin if center else - boid.global_transform.origin 
#	
	var power = max(to_center.length() - radius, 0)
	force = to_center.limit_length(power)
	return force
	
# Called when the node enters the scene tree for the first time.
func _ready():
	boid = get_parent()




