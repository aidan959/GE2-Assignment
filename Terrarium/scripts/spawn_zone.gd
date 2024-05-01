class_name SpawnPath extends Path3D

@export var spawnable_boids : Array[String] = []
@export_dir var boid_path : String = "res://scenes/Boids/"
var boid_scenes :Array[PackedScene] = []
func _ready():
	for spawnable_boid in spawnable_boids:
		var sheep_path = boid_path + spawnable_boid + ".tscn"
		var boid = load(boid_path + spawnable_boid + ".tscn")
		boid_scenes.push_back(boid)
	
