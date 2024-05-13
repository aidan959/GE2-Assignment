extends Path3D

var move_allowed = true  # Controls whether movement along the path is allowed
const path_speed = 10

func _ready():
	pass  # Replace with function body if necessary.

func _process(delta):
	if move_allowed:
		$PathFollow3D.progress += path_speed * delta

func set_movement_allowed(is_allowed):
	move_allowed = is_allowed
