class_name AntiSocial extends SteeringBehavior
	
@export var softness : float = 1000
var fake_zero : float = 0.0001

var needs_updating = true


# http://www.diva-portal.org/smash/get/diva2:675990/FULLTEXT01.pdf
func inv_square(dist: float) -> float:
	var e : float = 0.0
	if dist == 0:
		e = fake_zero
	return ((dist/softness) + e) ** -2


func on_draw_gizmos():
	pass

func calculate():
	var me_pos = boid.global_position
	var center_of_mass : Vector3 = Vector3.ZERO
	var force = Vector3.ZERO
	if boid.neighbours.size() <= 3:
		return Vector3.ZERO
	for other_boid in boid.neighbours:
		center_of_mass += other_boid.global_transform.origin
	center_of_mass /= boid.neighbours.size()
	force = center_of_mass - boid.global_transform.origin
	force = -force.normalized()

	return force

func _ready():
	boid = get_parent()

