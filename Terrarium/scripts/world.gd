extends Node3D

@onready var weather_instance = preload("res://scenes/weather.tscn").instantiate()

func _ready():
	add_child(weather_instance)
