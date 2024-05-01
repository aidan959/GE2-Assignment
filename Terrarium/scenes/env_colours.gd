extends Node3D

var environment : WorldEnvironment
@export var top_sky: Gradient
@export var horizon_sky: Gradient

var sun : DirectionalLight3D
@export var sun_colour : Gradient
@export var sun_intensity : Curve

var moon : DirectionalLight3D
@export var moon_colour : Gradient
@export var moon_intensity : Curve

@export var heat_colour : Gradient
