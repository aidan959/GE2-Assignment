class_name Cohesion extends SteeringBehavior
var center_of_mass = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	boid = get_parent()
	boid.count_neighbours = true

func on_draw_gizmos():
	DebugDraw3D.draw_arrow(boid.global_transform.origin, center_of_mass, Color.DARK_SEA_GREEN, 0.1)
	
func calculate():
	force = Vector3.ZERO
	center_of_mass = Vector3.ZERO
	if boid.neighbours.size() == 0:
		return center_of_mass

	for other_boid in boid.neighbours:
		center_of_mass += other_boid.global_position

	center_of_mass /= boid.neighbours.size()
	force = center_of_mass - boid.global_position
	#force = force.normalized()
	return force
	
