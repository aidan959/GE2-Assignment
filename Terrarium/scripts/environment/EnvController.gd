class_name EnvController extends Node

@export var sim_time : bool = true
@export var day_length : float = 240.0
@export_range(0, 2400, 0.01) var day_time = 120.0

@export var weather_duration : float = 30.0
@onready var weather_occured : bool = false

@onready var sunMoonParent = $SunMoon
@onready var sun_light : DirectionalLight3D = $SunMoon/SunLight
@onready var moon_light : DirectionalLight3D = $SunMoon/MoonLight
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var environment : WorldEnvironment = $WorldEnvironment
@onready var weather_controller = $WorldEnvironment/Weather

var rand_choice : int
@export var do_weather : bool = false
var is_heat_active : bool = false
var lerp_progress : float = 0.0
var original_top_sky_colour : Color
var original_horizon_sky_colour : Color
var transition_duration: float = 2.0

@export var top_sky: Gradient
@export var horizon_sky: Gradient
@export var sun_colour : Gradient
@export var sun_intensity : Curve
@export var moon_colour : Gradient
@export var moon_intensity : Curve
@export var heat_colour : Gradient

@onready var player = get_parent()

func runDay(delta):
	if sim_time:
		day_time += delta
		if day_time >= day_length:
			day_time = 0.0
			weather_occured = false
 
func updateLights(_delta):
	sun_light.rotation_degrees.x = (day_time / day_length) * 360 + 90
	moon_light.rotation_degrees.x = (day_time / day_length) * 360 + 270
	sun_light.light_color = sun_colour.sample(day_time / day_length)
	moon_light.light_color = moon_colour.sample(day_time / day_length)

func updateSkyColors(delta):
	var top_colour : Color
	var horizon_colour : Color

	if rand_choice == 2:  # Heat weather
		if weather_controller.weather_timer.time_left > 0:
			# Lerp to heat color
			top_colour = original_top_sky_colour.lerp(heat_colour.sample(day_time / day_length), lerp_progress)
			horizon_colour = original_horizon_sky_colour.lerp(heat_colour.sample(day_time / day_length), lerp_progress)
			if is_heat_active: lerp_progress += delta / weather_duration
			if lerp_progress >= 1.0:
				is_heat_active = false
				lerp_progress = 0.0
				
				original_top_sky_colour = world_environment.environment.sky.sky_material.get("sky_top_color")
				original_horizon_sky_colour = world_environment.environment.sky.sky_material.get("sky_horizon_color")
				
				
		else:
			# Lerp back to original colours
			#print("here", lerp_progress) 
			top_colour = original_top_sky_colour.lerp(top_sky.sample(day_time / day_length) ,lerp_progress)
			horizon_colour = original_horizon_sky_colour.lerp(top_sky.sample(day_time / day_length) ,lerp_progress)
			lerp_progress += delta /weather_duration
			if lerp_progress >= 1.0:
				rand_choice = 0
				lerp_progress = 0.0 
			
			
		world_environment.environment.sky.sky_material.set("sky_top_color", top_colour)
		world_environment.environment.sky.sky_material.set("sky_horizon_color", horizon_colour)
			
	else:
		world_environment.environment.sky.sky_material.set("sky_top_color", top_sky.sample(day_time / day_length))
		world_environment.environment.sky.sky_material.set("sky_horizon_color", horizon_sky.sample(day_time / day_length))
	

func consider_changing_weather():
	weather_occured = true
	if randi() % 3 == 0:
		change_weather()

func change_weather():
	rand_choice = randi() % 3
	var intensity = randf_range(500, 1500)
	weather_controller.start_timer(weather_duration)

	match rand_choice:
		0:
			weather_controller.rain(intensity)
			#print("rain weather")
		1:
			weather_controller.snow(intensity)
			#print("snow weather")
		2:
			weather_controller.heat()
			#print("hot weather")
			lerp_progress = 0.0
			is_heat_active = true
			original_top_sky_colour = world_environment.environment.sky.sky_material.get("sky_top_color")
			original_horizon_sky_colour = world_environment.environment.sky.sky_material.get("sky_horizon_color")

func _process(delta):
	updateLights(delta)
	runDay(delta)
	updateSkyColors(delta)
	if day_time >= day_length / 2 and not weather_occured and do_weather:
		consider_changing_weather()

func _physics_process(_delta):
	weather_controller.global_transform = player.global_transform
 
