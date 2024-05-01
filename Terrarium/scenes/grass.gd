class_name GrassFood extends Area3D
@export var fullness: float = 100.0  # Fullness percentage of the grass
var depletion_rate: float = 1.0  # Rate of the grass depletion

@export_range (0,10) var max_num_grazers : int = 5
var current_num_grazers = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	#print("Grass State" ,fullness)
	if current_num_grazers > 0 and fullness > 0:
		fullness -= current_num_grazers * depletion_rate * delta
		fullness = max(fullness, 0)  
		update_grass_state()


func update_grass_state():
	if fullness == 0:
		emit_signal("grass_depleted")  # Optionally handle this with a signal
		for sheep in get_overlapping_bodies():
			if sheep is Sheep:
				sheep.can_eat = false


func _on_body_entered(body : Node3D):
	if body is Sheep:
		current_num_grazers += 1
		body.can_eat = true
		

func _on_body_exit(body: Node3D):
	if body is Sheep:
		current_num_grazers -= 1
		body.can_eat= false

func is_full() -> bool:
	return current_num_grazers >= max_num_grazers
