@tool
class_name SpatialHashing extends Node3D
# inspired by - https://conkerjo.wordpress.com/2009/06/13/spatial-hashing-implementation-for-fast-2d-collisions/
var columns : int
var rows : int
var radius : float
var buckets : Dictionary = {}

@export_range(0.1, 20.0) var bucket_size: float = 10.0
@export var draw_gizmos: bool = false


func do_draw_gizmos():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draw_gizmos: do_draw_gizmos()
	
func _ready():
	for i in columns * rows:
		pass
