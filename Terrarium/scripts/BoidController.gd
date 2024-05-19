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

@export var shark_radius : float = 100


@export var neighbour_distance = 20
@export var avoid_distance = 20

@export var max_neighbours = 10
@export var boid_infometer : BoidInfometer
@export var player: Player
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
@export var spatial_hashing : SpatialHashing

var environment_controller : EnvController
var center : Node3D

func do_draw_gizmos():
	if Engine.is_editor_hint():
		DebugDraw3D.draw_sphere(global_position, radius, Color.ORANGE)
		DebugDraw3D.draw_sphere(global_position, shark_radius, Color.RED)
		


func _process(_delta):
	if draw_gizmos: do_draw_gizmos()
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed("spawn_boid_debug"):
		var pos = player.global_position
		pos += -player.camera.global_basis.z * 5
		var boid : Boid = spawn_boid("Sheep", pos)
		boid.velocity = -player.camera.global_basis.z * 5
		boid.look_at(pos + -player.camera.global_basis.z * 5, Vector3.UP)
func _physics_process(delta):
	spatial_hashing.boids_to_buckets()
func _ready():
	load_names()
	center = get_node_or_null(center_path)
	if not center:
		center = self
	if not spatial_hashing:
		for node in get_children():
			if node is SpatialHashing:
				spatial_hashing = node
				break
	if not player:
		for node in get_parent().get_children():
			if node is Player:
				player = node
				break
	for node in get_parent().get_children():
		var potential_pred = node.find_child("Predator", true)
		if potential_pred:
			predators.push_back(potential_pred.get_parent())
	environment_controller = player.environment_controller
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
func _spawn_boids_paramaterized(no_sheep, no_sharks, no_grass):
	spawn_amount["Sheep"] = no_sheep
	spawn_amount["Shark"] = no_sharks
	grass_count = no_grass
	_spawn_boids()
	
	
func _spawn_boids():
	if grass_scene:
		for i in grass_count:
			var grass = grass_scene.instantiate()
			var pos = Utils.random_point_in_unit_sphere() * radius
			pos.y = -4.5
			add_child(grass)
			grass.global_position = pos
			var grass_instance : GrassFood = grass
			grasses.push_back(grass_instance)

	for type in spawn_amount:
		for i in spawn_amount[type]:
			spawn_boid(type, null)
			

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
	if not boid.get_boid_type() in boids:
		return
	if boid_infometer and boid_infometer.saved_boid == boid:
		boid_infometer.clear_boids()
	var list_of_boids : Array = boids[boid.get_boid_type()]
	var index = list_of_boids.find(boid, 0)
	if index == -1: return
	list_of_boids.remove_at(index)
	for boid_a in list_of_boids:
		index = boid_a.neighbours.find(boid, 0)
		if index == -1: continue
		boid_a.neighbours.remove_at(index)
	names.push_back(boid.name)
	remove_child(boid)
	boid.queue_free()
	
func spawn_boid(type: String, pos = null) -> Boid: # pos is a vector3
	if pos and not pos is Vector3:
		push_error("pos must be set as a Vector3")
		pos = null
		
	var boid = boid_types[type].instantiate()
	if pos and pos is Vector3:
		pass
	elif boid.spawn_location in spawnable_zones:
		pos = spawnable_zones[boid.spawn_location].pick_random().get_spawn_location()
	else:
		pos= get_spawn_position(boid) # random spawn from center
		push_error(boid.name +" does not have a spawn zone.")

	add_child(boid)

	boid.global_position = pos
	boid.global_rotation = Vector3(0, randf_range(0, PI * 2.0),  0)
	boid.draw_gizmos_propagate(false)
	if not boid.get_boid_type() in boids:
		boids[boid.get_boid_type()] = []
	boid.hunger = randf_range(0.0, 0.1)
	boid.metabolism = randf_range(0.05, 0.06)
	boid.name = get_random_unique_name()
	
	boids[boid.get_boid_type()].push_back(boid)
	boid.environment_controller = environment_controller
	boid.look_at(center.global_position, Vector3.UP)

	
	var constrain = boid.get_node("Constrain")
	if  type == "Shark":
		var evict = boid.get_node("Evict")
		var shark_constrain = boid.get_node("SharkConstrain")
		constrain.center = center
		constrain.radius = shark_radius
		constrain.enabled = true
	elif constrain:
		constrain.center = center
		constrain.radius = radius
	return boid
