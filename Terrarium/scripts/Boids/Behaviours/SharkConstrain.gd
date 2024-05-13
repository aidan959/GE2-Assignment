class_name SharkConstrain extends SteeringBehavior

@export var water_top : float
@export var water_bottom : float

func on_draw_gizmos():
	pass
	#var center_pos = center.global_transform.origin if center else Vector3.ZERO 
	#DebugDraw3D.draw_sphere(center_pos, radius, Color.BEIGE)


func calculate():
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
