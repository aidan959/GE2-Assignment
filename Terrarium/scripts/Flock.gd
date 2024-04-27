class_name Flock extends Node

@export var sheep_scene:PackedScene

@export var count = 5

@export var radius = 100

@export var neighbor_distance = 20
@export var max_neighbors = 10

var boids = []
@export var draw_gizmos : bool = false
@export var cell_size = 10
@export var grid_size = 10000
@export var partition = true
var cells = {}

@export var center_path:NodePath
var center

func do_draw_gizmos():
	var size = 200
	var sub_divisions = size / cell_size
	DebugDraw3D.draw_grid(Vector3.ZERO, Vector3.RIGHT * size, Vector3.BACK * size, Vector2(sub_divisions, sub_divisions), Color.AQUAMARINE)
	# DebugDraw.draw_grid(Vector3.ZERO, Vector3.UP * size, Vector3.BACK * size, Vector2(sub_divisions, sub_divisions), Color.aquamarine)


func position_to_cell(p): 
	# Get rid of negatives!
	var pos = p + Vector3(10000, 10000, 10000)
	var f = floor(pos.x / cell_size)       
	var r = floor(pos.x / cell_size) + (floor(pos.y / cell_size) * grid_size) + (floor(pos.z / cell_size) * grid_size * grid_size)
	return r
	
func cell_to_position(cell):
	var z = floor(cell / (grid_size * grid_size))
	var y = floor((cell - (z * grid_size * grid_size)) / grid_size)
	var x = cell - (y * grid_size + (z * grid_size * grid_size)) 
	
	
	var p = Vector3(x, y, z) * cell_size
	p -= Vector3(10000, 10000, 10000) 
	return p
	
func do_partition():
	cells.clear()	
	for boid in boids:
		var key = position_to_cell(boid.transform.origin)
		if ! cells.has(key):
			cells[key] = []	
		cells[key].push_back(boid)

func _process(delta):
	if draw_gizmos: do_draw_gizmos()
	if partition:
		do_partition()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	center = get_node(center_path)
	var cell = position_to_cell(Vector3(-60, 59, 80))
	var p = cell_to_position(cell)
	for i in count:
		var sheep = sheep_scene.instantiate()		
		var pos = Utils.random_point_in_unit_sphere() * radius
		add_child(sheep)
		sheep.global_position = pos
		sheep.global_rotation = Vector3(0, randf_range(0, PI * 2.0),  0)

		var boid = sheep
		if boids.size() == 0:
			boid.draw_gizmos = true
			pass
		boids.push_back(boid)		
		
		var constrain = boid.get_node("Constrain")
		if constrain:
			# constrain.center_path = center_path
			constrain.center = center
			constrain.radius = radius
		

