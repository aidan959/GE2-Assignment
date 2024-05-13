extends Node3D


func _on_timer_timeout():
	#Delete particles after timeout
	queue_free()
