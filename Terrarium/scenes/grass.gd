class_name Grass extends Area3D

@export_range (0,10) var max_num_grazers : int = 5
var current_num_grazers = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _on_body_entered(body : Node3D):
	if body is Sheep:
		current_num_grazers += 1
		body.can_graze = true
		

func _on_body_exit(body: Node3D):
	if body is Sheep:
		current_num_grazers -= 1
		body.can_graze= false

func is_full() -> bool:
	return current_num_grazers >= max_num_grazers
