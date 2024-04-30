class_name Utils extends Node

static func random_point_in_unit_sphere() -> Vector3:
	var theta = randf_range(0, 2 * PI)
	var phi = randf_range(0, PI)
	var r = pow(randf_range(0, 1), 1.0/3.0)  # Cube root for uniform distribution

	var x = r * sin(phi) * cos(theta)
	var y = r * sin(phi) * sin(theta)
	var z = r * cos(phi)
	return Vector3(x, y, z)

static func random_flat_point_in_unit_sphere(_origin: Vector3) -> Vector3:
	var theta = randf_range(0, 2 * PI)
	var phi = randf_range(0, PI)
	var r = pow(randf_range(0, 1), 1.0/3.0)  # Cube root for uniform distribution

	var x = r * sin(phi) * cos(theta)
	var z = r * cos(phi)
	return Vector3(x, 1.0, z)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
