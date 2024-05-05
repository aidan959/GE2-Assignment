class_name SpawnZone extends Area3D


@export var spawn_type : Boid.SpawnLocations = Boid.SpawnLocations.LAND
@export var override_shape : BoxShape3D
@onready var collision_area : CollisionShape3D = $CollisionArea

var boid_scenes :Array[PackedScene] = []
func _ready():
	if override_shape:
		collision_area.shape = override_shape

func get_spawn_location() -> Vector3:
	print("getting point for: ")
	print(spawn_type)
	return Vector3.ZERO
