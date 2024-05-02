class_name SteeringBehavior extends Node

@export var weight = 1.0
@export var draw_gizmos = true

@export var sounds : Array[AudioStream] = []
@export_range(0.0, 1.0) var sound_weight : float = 0.5
@export_range(0.0, 1.0) var sound_volume : float = 1.0

var boid : Boid

@export var enabled = true: get = is_enabled, set = set_enabled

var force : Vector3 = Vector3.ZERO

func set_enabled(e):
	enabled = e 
	set_process(enabled)

func is_enabled():
	return enabled
	
func on_draw_gizmos():
	pass
	
func _process(_delta):	
	if draw_gizmos and enabled:
		on_draw_gizmos()

func has_sounds() -> bool:
	return not sounds.is_empty()
	
func get_random_sound() -> AudioStream:
	return sounds.pick_random()
