extends MeshInstance3D

@onready var camera = get_parent() as Camera3D

var offset = Vector3(0, 0, -1)  

func _process(delta):
	if camera:
		global_transform.origin = camera.global_transform.origin + camera.global_transform.basis.z * offset.z
		look_at(global_transform.origin - camera.global_transform.basis.z, Vector3.UP)
