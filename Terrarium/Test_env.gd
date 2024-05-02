class_name TestEnv extends Node

@export var sim_time : bool = true
@export var day_length : float = 60.0
@export_range(0,2400,0.01) var day_time = 10.0

@export var weather_duration : float = 10.0
@onready var weather_occured : bool = false

@onready var sunMoonParent = $SunMoon
@onready var sun_light : DirectionalLight3D = $SunMoon/SunLight
@onready var moon_light : DirectionalLight3D = $SunMoon/MoonLight
@onready var world_environment: WorldEnvironment = $WorldEnvironment

@onready var environment : WorldEnvironment = $WorldEnvironment
@onready var weather_controller = $WorldEnvironment/Weather



@export var top_sky: Gradient
@export var horizon_sky: Gradient
@export var sun_colour : Gradient
@export var sun_intensity : Curve
@export var moon_colour : Gradient
@export var moon_intensity : Curve
@export var heat_colour : Gradient

@onready var player = get_parent() 


func runDay(delta):
	if sim_time == true:
		day_time += delta 
		if day_time >= day_length:
			day_time = 0.0
			weather_occured = false
			
func updateLights(delta):
	sun_light.rotation_degrees.x =  (day_time / day_length) * 2 * PI * (180 / PI) + 90
	moon_light.rotation_degrees.x =  (day_time / day_length) * 2 * PI * (180 / PI) + 270
	
	sun_light.light_color = sun_colour.sample(day_time / day_length)
	moon_light.light_color = moon_colour.sample(day_time / day_length)
	
	world_environment.environment.sky.sky_material.set("sky_top_color", top_sky.sample(day_time / day_length))
	world_environment.environment.sky.sky_material.set("sky_horizon_color", horizon_sky.sample(day_time / day_length))
	#world_environment.environment.sky.sky_material.set("ground_bottom_color", top_sky.sample(day_time / day_length))
	#world_environment.environment.sky.sky_material.set("ground_horizon_color", horizon_sky.sample(day_time / day_length))
	
func consider_changing_weather():
	print("Weather Considered")
	if randi() % 3 == 0:  # 1/3 chance to trigger a weather change
		change_weather()

func change_weather():
		# Randomly decide what weather condition to trigger
		var rand_choice = randi() % 2 
		var intensity = randf_range(500, 1500) 
		weather_controller.start_timer(weather_duration)
		weather_occured = true
		rand_choice = 2
		match rand_choice:
			0:
				weather_controller.rain(2000)
				print("rain weather")
			1:
				weather_controller.snow(2000)
				print("snow weather")
			2:
				weather_controller.heat()
				print("hot weather")


func _process(delta):
	updateLights(delta)
	runDay(delta)
	if day_time >= day_length / 2 and weather_occured == false:
		consider_changing_weather()
		
func _physics_process(delta):
	weather_controller.global_transform = player.global_transform
	
