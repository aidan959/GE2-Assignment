class_name Escape extends SteeringBehavior

@export var softness : float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready():
	boid = get_parent()


func inv_square(distance: float) -> float:
	var e : float = 0.0
	if distance == 0:
		e = 0.000000001
	return ((distance/softness) + e) ** -2

func calculate():
	force = Vector3.ZERO
	if boid.flock.predators.size() ==0: return force
	for neighbour in boid.neighbours:
		if neighbour.is_currently_escaping:
			var diff = boid.global_position - boid.flock.predators[0].global_position
			force = (diff/diff.length()) * inv_square(diff.length()) * 0.5
			return force
	if boid.global_position.distance_to(boid.flock.predators[0].global_position) > boid.escape_distance : return force
	var diff = boid.global_position - boid.flock.predators[0].global_position
	force = (diff/diff.length()) * inv_square(diff.length())
	
	if draw_gizmos: DebugDraw3D.draw_arrow(boid.global_position, boid.flock.predators[0].global_position, Color.AQUA, clamp(force.length(),0.0, 10.0), true)
	return force
	
	

