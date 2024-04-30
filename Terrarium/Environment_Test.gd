class_name Environment_Controller extends Node

@onready var world_environment: WorldEnvironment = $DayNightCycle/WorldEnvironment
@onready var weather = get_node("weather")
@onready var weather_timer: Timer = $WeatherTimer

var day_length = 300.0  # Full day in seconds
var current_time = 0.0  # Current time in the cycle
var weather_event_occurred : bool = false



func _ready():
	set_weather_condition("clear")
	weather_timer.start()

func _process(delta):
	current_time += delta
	if current_time >= day_length:
		current_time = 0  # Reset the day cycle
		weather_event_occurred = false  # Reset the flag each day
	
	if current_time >= day_length / 2.0 and not weather_event_occurred:
		weather_event_occurred = true
		consider_changing_weather()
		
func consider_changing_weather():
	if randi() % 3 == 0:  # 1/3 chance to trigger a weather change
		change_weather()
		weather_timer.start(60)  # The weather effect lasts 60 seconds
	
	
	
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