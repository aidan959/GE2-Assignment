extends Control

var capture_mouse = false


@export var player : Player = null
@onready var boid_detector : BoidDetector = player.find_child("BoidDetector")

@export var viewport: SubViewport

var viewport_camera: Camera3D = null
@onready var name_tag :RichTextLabel = find_child("NameTag")
@onready var state_tag :RichTextLabel = find_child("StateTag")

@onready var health_bar :ProgressBar = find_child("HealthBar")
@onready var hunger_bar :ProgressBar = find_child("HungerBar")
@onready var sheep_cam :SubViewportContainer = find_child("SheepCamera")
func _ready():
	if !viewport:
		push_warning("Viewport has not been set.")
	else: 
		viewport.world_3d = viewport.find_world_3d()
		print(viewport.world_3d)
		viewport_camera = viewport.get_camera_3d()
		#sheep_cam. = viewport_texture

	if !boid_detector:
		push_warning("Boid detector has not been set.")
		
var saved_boid : Boid = null

func _process(_delta):
	if Input.is_action_pressed("target_boid"):
		if saved_boid:
			saved_boid = null
		else:
			saved_boid =boid_detector.detected_boid
		
func _physics_process(_delta):
	if !boid_detector:
		return
	var focus_boid : Boid = null
	if saved_boid: # TODO WHAT if sheep died + despawned?
		focus_boid = saved_boid

	elif boid_detector.detected_boid:
		focus_boid = boid_detector.detected_boid

	if !focus_boid:
		if viewport_camera is Follower:
			viewport_camera.sheep_target = null
		visible = false
		return
	
	if viewport_camera is Follower:
		viewport_camera.sheep_target = focus_boid
	visible = true
	health_bar.value = focus_boid.health
	hunger_bar.value = focus_boid.hunger
	name_tag.text = "[center]" + focus_boid.name + "[/center]"
	state_tag.text = "[center]" + focus_boid.BoidStates.keys()[focus_boid.current_state] + "[/center]"


