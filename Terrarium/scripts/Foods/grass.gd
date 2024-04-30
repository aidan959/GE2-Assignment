class_name Grass extends Food

func _on_body_entered(body : Node3D):
	if body is Sheep:
		current_num_eaters += 1
		body.can_eat = true
		

func _on_body_exit(body: Node3D):
	if body is Sheep:
		current_num_eaters -= 1
		body.can_eat= false

func is_full() -> bool:
	return current_num_eaters >= max_num_eaters
