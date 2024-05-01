@tool
class_name BoidSoundPlayer extends AudioStreamPlayer3D

@export var boid: Boid = null
@export var enabled: bool = true : set = _set_enabled 
var sound_enabled_behaviours : Dictionary= {}
@export_range(0.0, 30.0) var min_sound_interval: float = 5
var last_sound_played_time: float = -1


func _set_enabled(new_value: bool):
	if not boid:
		var parent = get_parent()
		if parent is Boid:
			boid = parent
			enabled = true
		else:
			push_error("BoidSoundPlayer must have 'boid' variable set, or be child of Boid. It cannot be enabled otherwise.")
			enabled = false
	else:
		enabled = new_value
	if enabled:
		get_behaviours_with_sounds()
	if !enabled:
		sound_enabled_behaviours.clear()
func _physics_process(delta):
	if playing: return
	var time_since_last_sound = Time.get_ticks_msec()/1000.0 - last_sound_played_time
	if time_since_last_sound >= min_sound_interval: return
	for behaviour in sound_enabled_behaviours:
		print(behaviour.force)
		
		

func get_behaviours_with_sounds():
	if !enabled: push_error("Cannot get behavioursw with sounds when disabled.")
	sound_enabled_behaviours.clear()
	for behaviour in boid.behaviours:
		if behaviour.behaviour_sounds.is_empty():continue

		sound_enabled_behaviours[behaviour] = null
