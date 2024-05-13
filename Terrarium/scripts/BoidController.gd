@tool
class_name BoidController extends Node3D


var boid_types : Dictionary = {
	"Sheep": preload("res://scenes/Boids/Sheep.tscn"),
	"Shark": preload("res://scenes/Boids/Shark.tscn")
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

@export var boid_infometer : BoidInfometer
var boids : Dictionary = {}
var grasses : Array[GrassFood] = []
var predators : Array[Node3D] = []
@export var spawnable_zones_node : Node3D

var spawnable_zones : Dictionary = {}

@export var spawn_on_ready : bool = false
var _draw_gizmos : bool = false
@export var draw_gizmos : bool  :
	get:
		return _draw_gizmos
	set(value):
		_draw_gizmos = value
		if boid_infometer:
			boid_infometer.draw_gizmos = _draw_gizmos
var cells = {}

@export var center_path : NodePath

@export var god_sheep : GodHead
var center
var boids_to_despawn : Array[Boid] = [] 
func do_draw_gizmos():
	if Engine.is_editor_hint():
		DebugDraw3D.draw_sphere(global_position, radius, Color.ORANGE)


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
	
	_init_spawn_zones()
	if spawn_on_ready:
		_spawn_boids()
	
	draw_gizmos = draw_gizmos # forces variable update
	
	if not god_sheep and "Sheep" in spawn_amount and spawn_amount["Sheep"] > 0:
		push_error("No god sheep set. Sheep will exhibit weird behaviours.")
func _init_spawn_zones():
	if not spawnable_zones_node:
		push_error("No spawnable zones node set.")
		return

	for spawn_zone in spawnable_zones_node.get_children():
		if not spawn_zone is SpawnZone:
			continue
		if not spawn_zone.spawn_type in spawnable_zones:
			spawnable_zones[spawn_zone.spawn_type] = []
		spawnable_zones[spawn_zone.spawn_type].push_back(spawn_zone)

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
			var pos 
			if boid.spawn_location in spawnable_zones:
				pos = spawnable_zones[boid.spawn_location].pick_random().get_spawn_location()
			else:
				pos= get_spawn_position(boid) # random spawn from center
				push_error(boid.name +" does not have a spawn zone.")

			add_child(boid)

			boid.global_position = pos
			boid.global_rotation = Vector3(0, randf_range(0, PI * 2.0),  0)
			boid.draw_gizmos_propagate(false)
			if not typeof(boid) in boids:
				boids[typeof(boid)] = []


			
			boid.hunger = randf_range(0.0, 0.1)
			boid.metabolism = randf_range(0.5, 0.9)
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
			push_error("AMBHIBIOUS NOT CONFIGURED")
			return Vector3.ZERO
		_:
			return Vector3.ZERO

func remove_boid(boid: Boid):
	if not typeof(boid) in boids:
		return
	if boid_infometer and boid_infometer.saved_boid == boid:
		boid_infometer.clear_boids()
	var list_of_boids : Array[Boid] = boids[typeof(boid)]
	var index = list_of_boids.find(boid, 0)
	list_of_boids.remove_at(index)
	for boid_a in list_of_boids:
		index = boid_a.neighbours.find(boid, 0)
		boid_a.neighbours.remove_at(index)
	
	boid.call_deferred("queue_free()")
	

