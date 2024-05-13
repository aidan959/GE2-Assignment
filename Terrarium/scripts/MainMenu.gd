extends Control

@export var player : Player
@export var menu_camera : Follower
@export var boid_controller : BoidController
@export var transition_duration = 10.0
@export_category("Music")
@export var menu_music: AudioStream
@export var game_music: AudioStream
@export var target_menu_music_volume = 1.0
@export var target_game_music_volume = 0.6



var menu_music_volume = 1.0
var game_music_volume = 0.0

var transition_timer = 0.0
var transition_complete = false
var do_transition = false

func _ready():
	get_player()
	get_camera()
	if not menu_camera:push_error("Main Menu will not function without a main camera in the scene.")
	if not player: push_error("Main Menu will not function without a player in the scene.")
	if not boid_controller: push_error("Main Menu will not function without a boid_controller in the scene.")
	
	if player:
		player.release_mouse()
		player.camera.current = false
		if player.music_player:
			player.music_player.stream = menu_music
			player.music_player.play()
			
	if menu_camera:
		menu_camera.current = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	if not player or not menu_camera or not boid_controller:
		return
	visible = false
	var transition_duration = 1.0
	var distance = (player.camera.global_transform.origin - menu_camera.global_transform.origin).length()
	# var direction = (player.camera.global_transform.origin - menu_camera.global_transform.origin).normalized()
	
	do_transition = true
	boid_controller._spawn_boids()
func get_player():
	if player: return
	
	for child in get_parent().get_children():
		if child is Player:
			player = child
			return
func _physics_process(delta):
	if not do_transition: return
	if transition_timer < transition_duration and not transition_complete:
		var progress = transition_timer / transition_duration

		menu_camera.global_transform.origin = menu_camera.global_transform.origin.lerp(player.camera.global_transform.origin, progress)
		update_music_volumes(progress)

		transition_timer += delta
	elif not transition_complete:
		# Transition complete
		menu_camera.global_transform.origin = player.camera.global_transform.origin
		transition_complete = true

		menu_camera.current = false
		player.camera.current = true
		player.capture_mouse()
		
func get_camera():
	if menu_camera: return
	
	for child in get_parent().get_children():
		if child is Follower:
			menu_camera = child
			return
func get_boid_controller():
	if boid_controller: return
	
	for child in get_parent().get_children():
		if child is BoidController:
			boid_controller = child
			return


func update_music_volumes(progress: float):
	var actual_volume : float
	if progress < 0.5:
		# Fading out menu music
		menu_music_volume = 1 -(progress * 2.0)
		actual_volume = remap(menu_music_volume, 0.0, 1.0,-70, -6)		
	else:
		if player.music_player.stream != game_music:
			player.music_player.stop()
			player.music_player.stream = game_music
			player.music_player.play()
		menu_music_volume = (progress - 0.5) * 2.0
		actual_volume = remap(menu_music_volume, 0.0, 1.0,-120, -12)

	player.music_player.volume_db = actual_volume
	
