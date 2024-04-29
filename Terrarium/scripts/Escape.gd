class_name Escape extends SteeringBehavior

var force = Vector3.ZERO
@export var softness : float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready():
	boid = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func can_graze(val: bool):
	print("")

func inv_square(distance: float) -> float:
	var e : float = 0.0
	if distance == 0:
		e = 0.000000001
	return ((distance/softness) + e) ** -2

func calculate():
	force = Vector3.ZERO
	if boid.predators.size() == 0 : return Vector3.ZERO
	var diff = boid.global_position - boid.flock.predators[0]
	(diff/diff.length()) * inv_square(diff.length)
	
	return force
	
	

