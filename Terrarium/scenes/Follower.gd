class_name Follower extends Camera3D

# Exported variables to adjust orbiting parameters
@export var orbit_speed: float = 1.0  # Speed of the orbit
@export var orbit_radius: float = 5.0  # Radius of the orbit
@export var orbit_height: float = 2.0  # Height of the camera from the sheep's position
@export var sheep_target: Node3D = null

@export_category("Lerping")
@export var do_lerp = false
@export var lerp_amount : float = 0.01
@export var start_lerp_height = 0.0
@export var start_lerp_radius = 1000.0

var is_orbiting = true

var angle: float = 0.0

# Reference to the sheep
	
func _physics_process(delta):
	if not sheep_target or not is_orbiting:
		return
	
	angle += orbit_speed * delta
	angle = fmod(angle, 2 * PI)
	
	var y : float
	if do_lerp:
		start_lerp_height = lerp(start_lerp_height, orbit_height, lerp_amount)
		start_lerp_radius = lerp(start_lerp_radius, orbit_radius, lerp_amount)
		y = start_lerp_height
	else:
		start_lerp_radius = orbit_radius
		y = orbit_height
	
	var x = start_lerp_radius * cos(angle)
	var z = start_lerp_radius * sin(angle)
	
	
	global_transform.origin = sheep_target.global_transform.origin + Vector3(x, y, z)
	
	
	look_at(sheep_target.global_transform.origin, Vector3.UP)
