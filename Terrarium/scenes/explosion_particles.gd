extends Node3D
@export var particles1 : GPUParticles3D 
@export var particles2 : GPUParticles3D
@export var particles3 : GPUParticles3D
@export var sheep : Sheep

func _ready():
	if not particles1: particles1 = $GPUParticles3D
	if not particles2: particles2 = $GPUParticles3D2
	if not particles3: particles3 = $GPUParticles3D3
	if not sheep: sheep = get_parent()

func explode():
	particles1.emitting = true
	particles2.emitting = true
	particles3.emitting = true
	

var finished_counter = 0
func increase_finished_counter():
	finished_counter += 1
	if finished_counter >= 3:
		sheep.despawn_me()
func _on_gpu_particles_3d_3_finished():
	increase_finished_counter()
