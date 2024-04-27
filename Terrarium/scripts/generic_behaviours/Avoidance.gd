class_name Avoidance extends SteeringBehavior
	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum ForceDirection {Normal, Incident, Up, Braking}
@export var softness : float = 10
var fake_zero : float = 0.0001
var force = Vector3.ZERO
var feelers = []
var space_state
var needs_updating = true
# http://www.diva-portal.org/smash/get/diva2:675990/FULLTEXT01.pdf
func inv_square(dist: float) -> float:
	var e : float = 0.0
	if dist == 0:
		e = fake_zero
	return ((dist/softness) + e) ** -2


func on_draw_gizmos():
	for i in feelers.size():
		var feeler = feelers[i]		
		
		if feeler.hit and draw_gizmos:
			DebugDraw3D.draw_line(boid.global_transform.origin, feeler.hit_target, Color.CHARTREUSE)
			DebugDraw3D.draw_arrow(feeler.hit_target, feeler.hit_target + feeler.normal, Color.BLUE, 0.1)
			DebugDraw3D.draw_arrow(feeler.hit_target, feeler.hit_target + feeler.force * weight, Color.RED, 0.1)			
		elif draw_gizmos:
			DebugDraw3D.draw_line(boid.global_transform.origin, feeler.end, Color.CHARTREUSE)

func calculate():
	var me = boid.global_position
	force = Vector3.ZERO
	for i in boid.neighbors.size():
			var other= boid.neighbors[i]
			var other_pos = other.global_position
			var diff = me - other_pos
			force += (diff/diff.length()) * inv_square(diff.length())
			
	return force

func _ready():
	boid = get_parent()
	space_state = boid.get_world_3d().direct_space_state

