class_name BoidDetector extends RayCast3D

var detected_boid :Sheep = null


func _physics_process(_delta):
	force_raycast_update() 
	if !is_colliding():
		detected_boid = null
		return
	var collider = get_collider()
	if collider is Sheep:
		detected_boid = collider
