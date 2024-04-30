class_name EnvironmentController extends Node

@onready var world_environment: WorldEnvironment = $DayNightCycle/WorldEnvironment
@onready var weather = get_node("weather")

var day_length = 60.0  # Full day in seconds
var current_time = 0.0  # Current time in the cycle

var sunrise_start : float = 0.2 * day_length
var sunrise_end : float = 0.3 * day_length
var sunset_start : float = 0.7 * day_length
var sunset_end : float = 0.8 * day_length

var weather_event_occurred : bool = false


func _ready():
	set_weather_condition("clear")

func _process(delta):
	current_time += delta
	if current_time >= day_length:
		current_time = 0  # Reset the day cycle
		weather_event_occurred = false  # Reset the flag each day

	# Trigger a random weather change only if it hasn't occurred today
	if not weather_event_occurred and sunrise_end < current_time and current_time < sunset_start:
		change_weather()
		weather_event_occurred = true  # Set the flag to true after a change
		
	if current_time > sunset_start:
		set_weather_condition("clear")

func change_weather():
		# Randomly decide what weather condition to trigger
		var rand_choice = randi() % 3  # Random integer 0, 1, or 2
		var intensity = randf_range(500, 1500) 
		match rand_choice:
			0:
				set_weather_condition("rain", intensity)
				print("rain weather")
			1:
				set_weather_condition("snow", intensity)
				print("snow weather")
			2:
				set_weather_condition("clear")
				print("clear weather")

func set_weather_condition(weather_data, intensity = 1000):
	var environment = world_environment.environment
	if not environment:
		return

	match weather_data:
		"rain":
			environment.volumetric_fog_enabled = true
			environment.volumetric_fog_density = 0.01
			weather.start_rain()
			weather.adjust_rain_intensity(intensity)

		"snow":
			environment.volumetric_fog_enabled = true
			environment.volumetric_fog_density = 0.03
			weather.start_snow()
			weather.adjust_snow_intensity(intensity)

		"clear":
			environment.volumetric_fog_enabled = false
			environment.volumetric_fog_density = 0.0
			weather.stop_rain()
			weather.stop_snow()
