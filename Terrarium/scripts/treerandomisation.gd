extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_scale_and_rotation()


# This function randomly adjusts the scale and y rotation of the tree.
func randomize_scale_and_rotation():
	var rng = RandomNumberGenerator.new()
	rng.randomize() 
	
	var random_scale = rng.randf_range(0.7, 1.3)
	scale = Vector3(random_scale, random_scale, random_scale)
	
	var random_rotation_y = rng.randf_range(0, 2 * PI) 
	rotation_degrees.y = rad_to_deg(random_rotation_y)
