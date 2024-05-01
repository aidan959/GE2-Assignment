class_name BoidSoundPlayer extends AudioStreamPlayer3D

@export var boid: Boid = null
@export var enabled: bool = true : set = _set_enabled 
func _ready():
	enabled = true

func _set_enabled(new_value: bool):
	if not boid:
		var parent = get_parent()
		if parent is Boid:
			boid = parent
		else:
			push_error("BoidSoundPlayer must have 'boid' variable set, or be child of Boid.")
			enabled = false
			return
			

func _process(delta):
	pass
