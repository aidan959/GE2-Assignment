class_name BoidController extends Node

@export var spawners: Dictionary  = {
	Sheep: 0.3,
	Shark: 0.1
}

var boid_types : Dictionary = {
	"Sheep": preload("res://scenes/Boids/Sheep.tscn"),
	"Shark": preload("res://scenes/Boids/Shark2.tscn")
}


@export var spawn_amount : Dictionary = {
	"Sheep": 70,
	"Shark": 5

}
 
@export var grass_scene:PackedScene
@export var grass_count = 1


@export var radius = 100

@export var neighbour_distance = 20
@export var avoid_distance = 20

@export var max_neighbours = 10
@export var environment_controller : EnvironmentController

var boids : Dictionary = {}
var grasses : Array[GrassFood] = []
var predators : Array[Node3D] = []
@export var spawn_on_ready : bool = false

@export var draw_gizmos : bool = false
var cells = {}

@export var center_path:NodePath
var center

func do_draw_gizmos():
	pass


func _process(_delta):
	if draw_gizmos: do_draw_gizmos()

func _ready():
	load_names()
	randomize()
	center = get_node(center_path)
	for node in get_parent().get_children():
		var potential_pred = node.find_child("Predator", true)
		if potential_pred:
			predators.push_back(potential_pred.get_parent())
	if spawn_on_ready:
		_spawn_boids()

func _spawn_boids():
	for i in grass_count:
		var grass = grass_scene.instantiate()
		var pos = Utils.random_point_in_unit_sphere() * radius
		pos.y = 0.3
		add_child(grass)
		grass.global_position = pos
		var grass_instance : GrassFood = grass
		grasses.push_back(grass_instance)
	
	for type in spawn_amount:
		for i in spawn_amount[type]:
			var _amount = spawn_amount[type]

			var boid = boid_types[type].instantiate()

			var pos = get_spawn_position(boid)

			add_child(boid)
			boid.global_position = pos
			boid.global_rotation = Vector3(0, randf_range(0, PI * 2.0),  0)

			if not typeof(boid) in boids:
				
				boids[typeof(boid)] = []


			boid.draw_gizmos_propagate(draw_gizmos)
			boid.hunger = randf_range(0.0, 0.1)
			boid.metabolism = randf_range(0.01, 0.05)
			boid.name = get_random_unique_name()
			
			boids[typeof(boid)].push_back(boid)
			
			var constrain = boid.get_node("Constrain")
			if constrain:
				constrain.center = center
				constrain.radius = radius
var names = []

func load_names():
	var file = FileAccess.open("res://data/sheep_names.txt",FileAccess.READ)
	
	while not file.eof_reached():
		var sheep_name = file.get_line().capitalize()
		if sheep_name != "":
			names.append(sheep_name)

func get_random_unique_name():
	if names.size() == 0:
		push_error("No more unique names available.")
		return ""
	
	var index = randi() % names.size()
	var sheep_name = names[index]
	names.remove_at(index) 
	return sheep_name
	
	
func get_spawn_position(boid: Boid) -> Vector3:
	match boid.spawn_location:
		boid.SpawnLocations.WATER:
			var pos = Utils.random_point_in_unit_sphere() * radius
			pos.y = -10.0
			return pos
		boid.SpawnLocations.LAND:
			var pos = Utils.random_point_in_unit_sphere() * radius
			pos.y = 0.0
			return pos
		boid.SpawnLocations.AMBHIBIOUS:
			push_error("AMBIBIOUS NOT CONFIGURED")
			return Vector3.ZERO
	return Vector3.ZERO


