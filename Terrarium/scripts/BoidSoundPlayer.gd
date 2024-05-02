class_name BoidSoundPlayer extends AudioStreamPlayer3D

@export var boid: Boid = null
@export var enabled: bool = true : set = _set_enabled 
var sound_enabled_behaviours : Dictionary= {}
@export_range(0.0, 30.0) var min_sound_interval: float = 10
@export var dead_music: AudioStream
@export var funny_dead_music: AudioStream
var funny_dead_music_chance = 0.1
var sound_cooldown_time: float = 0.0

@export var kill_sound: AudioStream
var has_died = false
var last_sound_played_time: float = -1

func _ready():
	enabled = enabled
	sound_cooldown_time = randf_range(0, min_sound_interval)

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
		

func _physics_process(_delta):
	if playing: return
	if not boid: return
	if boid.pause: return
	
	if boid.is_dead() and not has_died:
		has_died = true
		if kill_sound == null: return
		stream = kill_sound
		play()
		return
		
	if has_died:
		if dead_music == null: return
		var random_chance = randf()
		var dead_m = dead_music if random_chance > funny_dead_music_chance else funny_dead_music
		volume_db = -10.0
		stream = dead_m
		play()
		return
	if sound_cooldown_time > 0.0:
		sound_cooldown_time -= _delta
		return
	var sound_weight_acc : float = 0.0
	var behavior_sound_weights = {}
	for behaviour in sound_enabled_behaviours:
		if not behaviour.enabled:
			continue
		
		var sound_weight = behaviour.force.length() * behaviour.sound_weight
		behavior_sound_weights[behaviour] = sound_weight
		sound_weight_acc += sound_weight
	var chosen_sound : AudioStream= null
	var random_value = randf()  # Generate a random value between 0 and 1
	var cumulative_probability = 0.0

	
	for behaviour in behavior_sound_weights:
		var sound_weight = behavior_sound_weights[behaviour]
		var probability = sound_weight / sound_weight_acc
		cumulative_probability += probability
		
		if random_value * 50.0 <= (cumulative_probability):
			
			chosen_sound = behaviour.get_random_sound()
			break

	if chosen_sound != null:
		stream = chosen_sound
		pitch_scale = randf_range(0.7, 1.2)
		volume_db = randf_range(-15, -10)
		play()
		sound_cooldown_time = min_sound_interval
	

func add_behaviour_with_sound(behaviour: SteeringBehavior):
	if not behaviour.has_sounds(): return
	sound_enabled_behaviours[behaviour] = null
	
	
