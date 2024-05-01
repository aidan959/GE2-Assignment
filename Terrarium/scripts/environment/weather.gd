# Weather.gd
class_name Weather extends Node3D

@export var rain_intensity: float = 1000 : set = set_rain_intensity
@export var is_raining: bool = false : set = set_is_raining
@export var snow_intensity: float = 1000 : set = set_snow_intensity
@export var is_snowing: bool = false : set = set_is_snowing
@export var player: Player
@export var world_environment: WorldEnvironment 
@onready var rain_particles: GPUParticles3D = $RainParticles
@onready var snow_particles: GPUParticles3D = $SnowParticles


# Rain Methods
func set_is_raining(value: bool) -> void:
	is_raining = value
	update_weather_status()
	
func start_rain() -> void:
	set_is_raining(true)

func stop_rain() -> void:
	set_is_raining(false)

func set_rain_intensity(value: float) -> void:
	rain_intensity = value
	if is_raining:
		rain_particles.amount = roundi(rain_intensity)

func adjust_rain_intensity(intensity: float) -> void:
	set_rain_intensity(intensity)


# Snow Methods
func set_is_snowing(value: bool) -> void:
	is_snowing = value
	update_weather_status()

func start_snow() -> void:
	set_is_snowing(true)

func stop_snow() -> void:
	set_is_snowing(false)

func set_snow_intensity(value: float) -> void:
	snow_intensity = value
	if is_snowing:
		snow_particles.amount = roundi(snow_intensity)

func adjust_snow_intensity(intensity: float) -> void:
	set_snow_intensity(intensity)
	

func _physics_process(_delta):
	if player:
		global_transform.origin = player.global_transform.origin

func _ready() -> void:
	update_weather_status()

func update_weather_status() -> void:
	update_rain_status()
	update_snow_status()

func update_rain_status() -> void:
	rain_particles.emitting = is_raining
	if is_raining:
		rain_particles.amount = roundi(rain_intensity)

func update_snow_status() -> void:
	snow_particles.emitting = is_snowing
	if is_snowing:
		snow_particles.amount = roundi(snow_intensity)



