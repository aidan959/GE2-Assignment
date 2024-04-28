# Weather.gd
class_name Weather extends Node3D

@export var rain_intensity: float = 1000 : set = set_rain_intensity
@export var is_raining: bool = false : set = set_is_raining
#@export var snow_intensity: float = 1000 : set = set_snow_intensity
#@export var is_snowing: bool = false : set = set_is_snowing

@onready var rain_particles: GPUParticles3D = $RainParticles
#@onready var snow_particles: GPUParticles3D = $SnowParticles
@onready var world_environment: WorldEnvironment = $WorldEnvironment

func _ready() -> void:
	update_weather_status()

func set_is_raining(value: bool) -> void:
	is_raining = value
	update_weather_status()

func set_rain_intensity(value: float) -> void:
	rain_intensity = value
	if is_raining:
		rain_particles.amount = rain_intensity


func update_weather_status() -> void:
	update_rain_status()
	#update_snow_status()

func update_rain_status() -> void:
	print("is_raining", is_raining)
	rain_particles.emitting = is_raining
	if is_raining:
		rain_particles.amount = rain_intensity

func start_rain() -> void:
	set_is_raining(true)

func stop_rain() -> void:
	set_is_raining(false)

func adjust_rain_intensity(intensity: float) -> void:
	set_rain_intensity(intensity)

