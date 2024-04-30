extends Control

var capture_mouse = false


@export var player : Player = null
@onready var boid_detector : BoidDetector = player.find_child("BoidDetector")

@export var viewport: SubViewport

var viewport_camera: Camera3D = null
@onready var health_bar :ProgressBar = find_child("HealthBar")
@onready var hunger_bar :ProgressBar = find_child("HungerBar")
@onready var sheep_cam :TextureRect = find_child("SheepCamera")
func _ready():
	if viewport:
		viewport.get_camera_3d()
		push_warning("Viewport has not been set.")
		
	if !boid_detector:
		push_warning("Boid detector has not been set.")
		
func _physics_process(delta):
	if !boid_detector:
		return
	if boid_detector.detected_boid:
		sheep_cam.texture.viewport_path = sheep_cam.get_path()
		if viewport_camera is Follower:
			viewport_camera.sheep_target = boid_detector.detected_boid
		visible = true
		health_bar.value = boid_detector.detected_boid.health
		hunger_bar.value = boid_detector.detected_boid.hunger
	if !boid_detector.detected_boid:
		if viewport_camera is Follower:
			viewport_camera.sheep_target = null
		visible = false



