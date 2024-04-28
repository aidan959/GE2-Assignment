extends Node3D

var time : float
@export var length : float = 300.0
@export var start_time : float = 0.3
var time_rate : float 


var environment : WorldEnvironment
@export var top_sky_colour: Gradient
@export var horizon_sky_colour: Gradient


var sun : DirectionalLight3D
@export var sun_colour : Gradient
@export var sun_intensity : Curve

var moon : DirectionalLight3D
@export var moon_colour : Gradient
@export var moon_intensity : Curve



func _ready():
	time_rate = 1.0 / length
	time = start_time
	sun = get_node("Sun")
	moon = get_node("Moon")
	environment = get_node("WorldEnvironment")

	
func _process(delta):
	time += time_rate * delta
	if time >= 1.0:
		time = 0.0
		
	# Sun 
	sun.rotation_degrees.x = time * 360 +90
	sun.light_color = sun_colour.sample(time)
	sun.light_energy = sun_intensity.sample(time)
	
	#Moon
	moon.rotation_degrees.x = time * 360 + 270
	moon.light_color = moon_colour.sample(time)
	moon.light_energy = moon_intensity.sample(time)

	
	sun.visible = sun.light_energy > 0
	moon.visible = moon.light_energy > 0

	environment.environment.sky.sky_material.set("sky_top_color", top_sky_colour.sample(time))
	environment.environment.sky.sky_material.set("sky_horizon_color", horizon_sky_colour.sample(time))
	environment.environment.sky.sky_material.set("ground_bottom_color", top_sky_colour.sample(time))
	environment.environment.sky.sky_material.set("ground_horizon_color", horizon_sky_colour.sample(time))
