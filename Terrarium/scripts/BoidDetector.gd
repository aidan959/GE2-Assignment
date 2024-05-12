class_name BoidDetector extends RayCast3D

var detected_boid : Boid = null


func _physics_process(_delta):
	force_raycast_update() 
	if !is_colliding():
		if detected_boid: detected_boid.is_currently_selected = false
		detected_boid = null
		return
	var collider = get_collider()
	if collider is Boid:
		detected_boid = collider
		detected_boid.is_currently_selected = true
	else:
		return
	
	print(detected_boid.influencing_weights)
	
