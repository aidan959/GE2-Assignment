class_name Follower extends Camera3D

# Exported variables to adjust orbiting parameters
@export var orbit_speed: float = 1.0  # Speed of the orbit
@export var orbit_radius: float = 5.0  # Radius of the orbit
@export var orbit_height: float = 2.0  # Height of the camera from the sheep's position

# Variable to keep track of the angle
var angle: float = 0.0

# Reference to the sheep
var sheep_target: Sheep = null

func _physics_process(delta):
	if sheep_target:
		# Update the angle based on the orbit speed and delta time
		angle += orbit_speed * delta
		angle = fmod(angle, 2 * PI)  # Keep the angle within 0 to 2*PI for a full rotation
		
		# Calculate the new position using trigonometric functions
		var x = orbit_radius * cos(angle)
		var z = orbit_radius * sin(angle)
		var y = orbit_height
		
		# Update the camera's global position
		global_transform.origin = sheep_target.global_transform.origin + Vector3(x, y, z)
		
		# Make the camera look at the sheep
		look_at(sheep_target.global_transform.origin, Vector3.UP)
