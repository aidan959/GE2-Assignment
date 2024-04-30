class_name Grazer extends SteeringBehavior

var force = Vector3.ZERO
@export var softness : float = 10.0

func _ready():
	boid = get_parent()


func inv_square(hunger: float) -> float:
	var e : float = 0.0
	if hunger == 0:
		e = 0.000000001
	return ((hunger/softness) + e) ** -2

func calculate():
	force = Vector3.ZERO
	if boid.nearest_grass == null: return Vector3.ZERO
	
	if draw_gizmos:
		DebugDraw3D.draw_line(boid.global_position, boid.nearest_grass.global_position, Color.BLUE_VIOLET)
	
	var center_of_mass : Vector3 = boid.nearest_grass.global_position

	force = center_of_mass - boid.global_transform.origin
	force = force.normalized()
	
	force *= boid.hunger
	return force
	
	

