@tool
class_name SpawnZone extends Area3D


@export var spawn_type : Boid.SpawnLocations = Boid.SpawnLocations.LAND
@export var  override_shape : BoxShape3D
@onready var collision_area : CollisionShape3D = $CollisionArea
@export var draw_gizmos : bool = false
var boid_scenes :Array[PackedScene] = []
@onready var box_shape : BoxShape3D
func _ready():
	if override_shape:
		collision_area.shape = override_shape
	box_shape = collision_area.shape
	
func _process(delta):
	if Engine.is_editor_hint() and draw_gizmos and visible:	
		if override_shape:
			collision_area.shape = override_shape
		box_shape = collision_area.shape
		
		var box_color : Color 
		match spawn_type:
			Boid.SpawnLocations.LAND:
				box_color = Color.GREEN
			Boid.SpawnLocations.WATER:
				box_color = Color.RED
			_:
				box_color = Color.PURPLE
				
		DebugDraw3D.draw_box((global_position - (box_shape.size/2)) * rotation, global_basis, box_shape.size, box_color)

func get_spawn_location() -> Vector3:
	var position = global_position
	var rotation = global_rotation
	
	var size = box_shape.size
	
	var random_point = Vector3(
		randf_range(position.x - size.x / 2, position.x + size.x / 2),
		randf_range(position.y - size.y / 2, position.y + size.y / 2),
		randf_range(position.z - size.z / 2, position.z + size.z / 2)
	) 

	return (random_point)
