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
	pass

func calculate():
	var me_pos = boid.global_position
	force = Vector3.ZERO
	for other_boid in boid.neighbors:
		var other_pos = other_boid.global_position
		var diff = other_pos - me_pos
		var distance = diff.length()
		force += (diff/distance) * inv_square(distance)
		DebugDraw3D.draw_line(boid.global_position, boid.global_position + force, Color.BLACK, 1)
			
	return force

func _ready():
	boid = get_parent()
	space_state = boid.get_world_3d().direct_space_state

