extends Node

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var weather = get_node("weather")

var day_length = 60.0  # Full day in seconds.
var current_time = 0.0  # Current time in the cycle

var sunrise_start = 0.2
var sunrise_end = 0.3
var sunset_start = 0.7
var sunset_end = 0.8

func _ready():
	set_weather_condition("rain")

func _process(delta):
	current_time += delta
	if current_time >= day_length:
		current_time = 0  

	update_environment(current_time / day_length)

func update_environment(phase: float):
	var environment = world_environment.environment
	if not environment:
		return

func set_weather_condition(weather_data):
	var environment = world_environment.environment
	if not environment:
		return

	match weather_data:
		"rain":
			environment.volumetric_fog_enabled = true
			environment.volumetric_fog_density = 0.08
			weather.start_rain()
			weather.set_rain_intensity(1000)

		"snow":
			environment.volumetric_fog_enabled = true
			environment.volumetric_fog_density = 0.15

		"clear":
			environment.volumetric_fog_enabled = false
			environment.volumetric_fog_density = 0.0
			weather.stop_rain()
