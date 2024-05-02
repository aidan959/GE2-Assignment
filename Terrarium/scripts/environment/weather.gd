class_name Weather extends Node3D

@onready var world_environment : WorldEnvironment = get_parent()
@onready var rain_particles: GPUParticles3D = $RainParticles
@onready var snow_particles: GPUParticles3D = $SnowParticles
@onready var weather_timer: Timer = $WeatherTimer

@export var fog_density_curve : Curve
@export var fog_color_gradient : Gradient

var fog_time : float
var is_fog : bool : set = toggle_fog 
var is_reset_fog : bool = false
var target_fog_density : float = 0.01

func start_timer(time : float):
	weather_timer.start(time)
	fog_time = time

func _on_weather_timer_timeout():
	clear_weather()
	is_fog = false

func clear_weather():
	rain_particles.emitting = false
	snow_particles.emitting = false
	target_fog_density = 0.01
	
func rain(intensity : float):
	rain_particles.emitting = true
	rain_particles.amount = intensity
	is_fog = true

func snow(intensity : float):
	snow_particles.emitting = true
	snow_particles.amount = intensity
	is_fog = true
	
func toggle_fog(do_fog : bool):
	is_fog = do_fog
	if is_fog:
		target_fog_density = 0.1
	else:
		target_fog_density = 0.01

func _physics_process(delta):
	world_environment.environment.volumetric_fog_density = lerp(world_environment.environment.volumetric_fog_density, target_fog_density, 0.005)
		
