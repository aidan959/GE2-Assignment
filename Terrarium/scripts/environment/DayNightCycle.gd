extends Node3D

@onready var length : float = get_parent().day_length
@onready var time : float = get_parent().current_time
var start_time : float 
var time_rate : float 



var environment : WorldEnvironment
@export var top_sky_colour: Gradient
@export var horizon_sky_colour: Gradient

var sun : DirectionalLight3D
@export var sun_colour : Gradient
@export var heat_colour : Gradient
@export var sun_intensity : Curve

var current_sun_color
var target_sun_color
var interpolating_color = false
var color_lerp_time = 0.0
var color_lerp_duration = 2.0  # Duration over which to interpolate the color

var moon : DirectionalLight3D
@export var moon_colour : Gradient
@export var moon_intensity : Curve

var controller_state

func _ready():
	time_rate = 1.0 / length
	sun = get_node("Sun")
	moon = get_node("Moon")
	environment = get_node("WorldEnvironment")
	controller_state = get_parent()


	
func _process(delta):
	
	time += time_rate * delta
	if time >= 1.0:
		time = 0.0
		
	
	# Sun 
	sun.rotation_degrees.x = time * 360 +90
	sun.light_energy = sun_intensity.sample(time)

	if controller_state.is_heat:
		sun.light_color = heat_colour.sample(time)
	else:
		sun.light_color = sun_colour.sample(time)
		
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
		
