class_name Food extends Area3D

@export_range (0,10) var max_num_eaters : int = 5
var current_num_eaters = 0

func _on_body_entered(body : Node3D):
	if body is Boid:
		current_num_eaters += 1
		body.can_eat = true
		

func _on_body_exit(body: Node3D):
	if body is Boid:
		current_num_eaters -= 1
		body.can_eat= false

func is_full() -> bool:
	return current_num_eaters >= max_num_eaters
