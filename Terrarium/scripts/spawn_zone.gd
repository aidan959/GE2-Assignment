class_name SpawnZone extends Area3D


@export var spawn_type : Boid.SpawnLocations = Boid.SpawnLocations.LAND
@export var  override_shape : BoxShape3D
@onready var collision_area : CollisionShape3D = $CollisionArea

var boid_scenes :Array[PackedScene] = []
func _ready():
	if override_shape:
		collision_area.shape = override_shape

func get_spawn_location() -> Vector3:
	var box_shape : BoxShape3D
	if override_shape:
		box_shape = override_shape
	else:
		box_shape = collision_area.shape
	var position = global_position
	var rotation = global_rotation
	var size = box_shape.size
	
	# Generate random coordinates within the bounds of the BoxShape3D
	var random_point = Vector3(
		randf_range(position.x - size.x / 2, position.x + size.x / 2),
		randf_range(position.y - size.y / 2, position.y + size.y / 2),
		randf_range(position.z - size.z / 2, position.z + size.z / 2)
	)

	return random_point * rotation
