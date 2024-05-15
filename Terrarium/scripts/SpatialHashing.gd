@tool
class_name SpatialHashing extends Node3D
# inspired by - https://conkerjo.wordpress.com/2009/06/13/spatial-hashing-implementation-for-fast-2d-collisions/
var columns : int
var rows : int
var pages : int
var radius : float
var buckets : Dictionary = {}
@onready var boid_controller : BoidController = get_parent()
@export_range(0.1, 20.0) var bucket_size: float = 10.0
@export var draw_gizmos: bool = false

var grid_x : int = 0
var grid_y : int = 0
var grid_z : int = 0
var center : Vector3 = Vector3.ZERO

var min_x
var max_x
var min_y
var max_y
var min_z
var max_z 
@export var a = false
var inv_bucket_size : float = 0.0
func establish_grid_params():
	var parent : BoidController = get_parent()
	radius = parent.radius
	min_x = center.x - radius
	max_x = center.x + radius
	min_y = center.y - radius
	max_y = center.y + radius
	min_z = center.z - radius
	max_z = center.z + radius
	grid_x = int(snapped((max_x - min_x) / bucket_size, 1))
	grid_y = int(snapped((max_y - min_y) / bucket_size, 1))
	grid_z = int(snapped((max_z - min_z) / bucket_size, 1))
	inv_bucket_size = 1.0 / bucket_size
func do_draw_gizmos():
	
	establish_grid_params()
	
	for i in grid_x:
		for j in grid_y: 
			for k in grid_z:
				var pos = Vector3(min_x + (i + 0.5) * bucket_size, min_y + (j + 0.5) * bucket_size, min_z + (k + 0.5) * bucket_size)
				var id_x = int((pos.x - min_x) / bucket_size)
				var id_y = int((pos.y - min_y) / bucket_size)
				var id_z = int((pos.z - min_z) / bucket_size)
				var unique_id = id_x + id_y * grid_x + id_z * (grid_x * grid_y)
				#print("id = ", unique_id, " pos: ", pos)
				DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, Vector3(bucket_size,bucket_size,bucket_size), Color.PURPLE, true)
				
	#DebugDraw3D.draw_box(get_position_from_id(560),Quaternion.IDENTITY, Vector3(bucket_size,bucket_size,bucket_size), Color.RED, true)
	DebugDraw3D.draw_box(get_position_from_id(get_id_from_position(Vector3(-40, 80, 40))),Quaternion.IDENTITY, Vector3(bucket_size,bucket_size,bucket_size), Color.RED, true)
	
func boids_to_buckets():
	clear_buckets()
	for type in boid_controller.boids:
		for boid in boid_controller.boids[type]:
			var bucket_id = get_id_from_position(boid.global_position)
			if not buckets.has(bucket_id):
				buckets[bucket_id] = []
			buckets[bucket_id].push_back(boid)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
		
	if not Engine.is_editor_hint(): return

	if bucket_size < 4:
		draw_gizmos = false
	if draw_gizmos: do_draw_gizmos()
	
func clear_buckets():
	buckets.clear()
	for i in grid_x * grid_y * grid_z:
		buckets[i] = []
func register_boid( boid : Boid):
	var cell_id = get_id_for_boid(boid)
	buckets[cell_id].push_back(boid)
	
func get_id_for_boid(boid: Boid) -> int:
	var x_index = int((position.x - min_x) / bucket_size)
	var y_index = int((position.y - min_y) / bucket_size)
	var z_index = int((position.z - min_z) / bucket_size)
	
	return x_index + y_index * grid_x + z_index * (grid_x * grid_y)
func get_id_for_boid1(pos: Vector3) -> int:
	return int(floor(pos.x * inv_bucket_size) + floor(pos.y * inv_bucket_size) + floor(pos.z * inv_bucket_size))
func get_position_from_id(bucket_id: int) -> Vector3:
	var id_z = bucket_id / (grid_x * grid_y)
	var id_y = (bucket_id / grid_x) % grid_y
	var id_x = bucket_id % grid_x

	var pos_x = min_x + (id_x + 0.5) * bucket_size
	var pos_y = min_y + (id_y + 0.5) * bucket_size
	var pos_z = min_z + (id_z + 0.5) * bucket_size

	return Vector3(pos_x, pos_y, pos_z)
func get_id_from_position(position: Vector3) -> int:
	var id_x = int((position.x - min_x) / bucket_size)
	var id_y = int((position.y - min_y) / bucket_size)
	var id_z = int((position.z - min_z) / bucket_size)

	return id_x + id_y * grid_x + id_z * (grid_x * grid_y)
func _ready():
	var parent : BoidController = get_parent()
	center = parent.global_position
	establish_grid_params()


func get_grid_center_from_bucket_id(bucket_id: int) -> Vector3:
	var z_index = bucket_id % grid_z
	var y_index = (bucket_id / grid_z) % grid_y
	var x_index = bucket_id / (grid_y * grid_z)

	var center_x = (x_index % grid_x) * bucket_size + bucket_size * 0.5
	var center_y = y_index * bucket_size + bucket_size * 0.5
	var center_z = z_index * bucket_size + bucket_size * 0.5

	return Vector3(center_x, center_y, center_z)


func get_boid_in_adjacent_nodes(boid: Boid) -> Array[Boid]:
	var neighbours : Array[Boid] = [] 
	for dz in [0, -1, 1]: for dy in [0, -1, 1]: for dx in [0,-1, 1]:
		var pos = boid.global_position + Vector3(dx * bucket_size, dy * bucket_size, dz * bucket_size)
		var bucket_id = get_id_from_position(pos)
		if draw_gizmos:
			var grid_pos = get_position_from_id(bucket_id)
			DebugDraw3D.draw_aabb_ab(grid_pos, Vector3(bucket_size,bucket_size,bucket_size))
		if not buckets.has(bucket_id):
			return []
		for b : Boid in buckets[bucket_id]:
			if b == boid: continue # self
			if b.get_boid_type() != boid.get_boid_type(): continue # not matching type
			if draw_gizmos:
				DebugDraw3D.draw_box(boid.global_position, Quaternion.IDENTITY, Vector3(1,1,1),Color.DARK_GOLDENROD, true )
			if boid.global_position.distance_to(b.global_position) < boid.neighbour_distance:
				neighbours.push_back(b)
				if neighbours.size() >= boid_controller.max_neighbours:
					return neighbours
	return neighbours # should not be possible
				

