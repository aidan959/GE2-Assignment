@tool
class_name SpawnZone extends Node3D

@export var spawn_type : Boid.SpawnLocations = Boid.SpawnLocations.LAND
@export var shape : BoxShape3D
@export var draw_gizmos : bool = false
var boid_scenes :Array[PackedScene] = []
func _ready():
	if not shape:
		push_error("SpawnZone does not have box shape set!")
func _process(_delta):
	if Engine.is_editor_hint() and draw_gizmos and visible and shape:	
		
		var box_color : Color 
		match spawn_type:
			Boid.SpawnLocations.LAND:
				box_color = Color.GREEN
			Boid.SpawnLocations.WATER:
				box_color = Color.RED
			_:
				box_color = Color.PURPLE
				
		DebugDraw3D.draw_box(global_position - (shape.size/2), global_basis, shape.size, box_color)

func get_spawn_location() -> Vector3:
	var pos = global_position
	
	var size = shape.size
	
	var random_point = Vector3(
		randf_range(pos.x - size.x / 2, pos.x + size.x / 2),
		randf_range(pos.y - size.y / 2, pos.y + size.y / 2),
		randf_range(pos.z - size.z / 2, pos.z + size.z / 2)
	) 

	return (random_point)
