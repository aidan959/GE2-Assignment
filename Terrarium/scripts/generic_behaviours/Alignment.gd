class_name Alignment extends SteeringBehavior

var force = Vector3.ZERO
var desired = Vector3.ZERO

func _ready():
	boid = get_parent()
	boid.count_neighbors = true

func on_draw_gizmos():
	DebugDraw3D.draw_arrow(boid.global_transform.origin, boid.global_transform.origin + desired * weight, Color.GAINSBORO, 0.1)
	
func calculate():
	desired = Vector3.ZERO
	if boid.neighbors.size() < 0:
		return Vector3.ZERO
	for other_boid in boid.neighbors:
		desired += other_boid.global_transform.basis.y
	
	force = desired.normalized() - boid.velocity
	return force
	
