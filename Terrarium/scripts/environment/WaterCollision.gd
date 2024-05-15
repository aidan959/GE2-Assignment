extends Area3D

func _on_body_entered(body):

	if body is Player:
		body.current_movement_state = Player.movement_states.SWIM
		
	elif body is Boid:
		body.is_in_water = true
	
func _on_body_exited(body):
	if body is Player:
		body.current_movement_state = Player.movement_states.MOVE
		
	elif body is Boid:
		body.is_in_water = false
	
